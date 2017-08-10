//
//  AKPhaseDistortionOscillatorBankDSPKernel.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

#pragma once

#import "AKBankDSPKernel.hpp"

enum {
    phaseDistortionAddress = 0,
    attackDurationAddress = 1,
    decayDurationAddress = 2,
    sustainLevelAddress = 3,
    releaseDurationAddress = 4,
    detuningOffsetAddress = 5,
    detuningMultiplierAddress = 6
};

class AKPhaseDistortionOscillatorBankDSPKernel : public AKBankDSPKernel, public AKOutputBuffered {
public:
    // MARK: Types
    struct NoteState {
        NoteState* next;
        NoteState* prev;
        AKPhaseDistortionOscillatorBankDSPKernel* kernel;
        
        enum { stageOff, stageOn, stageRelease };
        int stage = stageOff;
        
        float internalGate = 0;
        float amp = 0;
        float velocityAmp = 0;
        
        sp_adsr *adsr;
        sp_tabread *tab;
        sp_phasor *phs;
        sp_pdhalf *pdhalf;
        
        void init() {
            sp_adsr_create(&adsr);
            sp_adsr_init(kernel->sp, adsr);
            
            sp_pdhalf_create(&pdhalf);
            sp_tabread_create(&tab);
            sp_tabread_init(kernel->sp, tab, kernel->ftbl, 1);
            sp_phasor_create(&phs);
            
            sp_pdhalf_init(kernel->sp, pdhalf);
            sp_phasor_init(kernel->sp, phs, 0);

            phs->freq = 0;
        }

        
        void clear() {
            stage = stageOff;
            amp = 0;
        }
        
        // linked list management
        void remove() {
            if (prev) prev->next = next;
            else kernel->playingNotes = next;
            
            if (next) next->prev = prev;
            
            //prev = next = nullptr; Had to remove due to a click, potentially bad
            
            --kernel->playingNotesCount;

            sp_pdhalf_destroy(&pdhalf);
            sp_tabread_destroy(&tab);
            sp_phasor_destroy(&phs);
        }
        
        void add() {
            init();
            prev = nullptr;
            next = kernel->playingNotes;
            if (next) next->prev = this;
            kernel->playingNotes = this;
            ++kernel->playingNotesCount;
        }
        
        void noteOn(int noteNumber, int velocity) {
            noteOn(noteNumber, velocity, (float)noteToHz(noteNumber));
        }
        
        void noteOn(int noteNumber, int velocity, float frequency) {
            if (velocity == 0) {
                if (stage == stageOn) {
                    stage = stageRelease;
                    internalGate = 0;
                }
            } else {
                if (stage == stageOff) { add(); }
                phs->freq = frequency;
                velocityAmp = (float)pow2(velocity / 127.);
                stage = stageOn;
                internalGate = 1;
            }
        }
        
        
        void run(int frameCount, float* outL, float* outR)
        {
            float originalFrequency = phs->freq;
            phs->freq *= kernel->detuningMultiplier;
            phs->freq += kernel->detuningOffset;
            phs->freq = clamp(phs->freq, 0.0f, 22050.0f);
            pdhalf->amount = kernel->phaseDistortion;

            adsr->atk = (float)kernel->attackDuration;
            adsr->dec = (float)kernel->decayDuration;
            adsr->sus = (float)kernel->sustainLevel;
            adsr->rel = (float)kernel->releaseDuration;

            for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
                float temp = 0;
                float pd = 0;
                float ph = 0;
                sp_adsr_compute(kernel->sp, adsr, &internalGate, &amp);

                sp_phasor_compute(kernel->sp, phs, NULL, &ph);
                sp_pdhalf_compute(kernel->sp, pdhalf, &ph, &pd);
                tab->index = pd;
                sp_tabread_compute(kernel->sp, tab, NULL, &temp);

                *outL++ += velocityAmp * amp * temp;
                *outR++ += velocityAmp * amp * temp;
                
            }
            phs->freq = originalFrequency;
            if (stage == stageRelease && amp < 0.00001) {
                clear();
                remove();
            }
        }
        
    };

    // MARK: Member Functions

    AKPhaseDistortionOscillatorBankDSPKernel() {
        noteStates.resize(128);
        for (NoteState& state : noteStates) {
            state.kernel = this;
        }
    }

    void setupWaveform(uint32_t size) {
        ftbl_size = size;
        sp_ftbl_create(sp, &ftbl, ftbl_size);
    }

    void setWaveformValue(uint32_t index, float value) {
        ftbl->tbl[index] = value;
    }

    void reset() {
        for (NoteState& state : noteStates) {
            state.clear();
        }
        playingNotes = nullptr;
        phaseDistortionRamper.reset();
        AKBankDSPKernel::reset();
    }
    
    standardBankKernelFunctions()

    void setPhaseDistortion(float value) {
        phaseDistortion = clamp(value, -1.0f, 1.0f);
        phaseDistortionRamper.setImmediate(phaseDistortion);
    }

    void setParameter(AUParameterAddress address, AUValue value) {
        switch (address) {
                
            case phaseDistortionAddress:
                phaseDistortionRamper.setUIValue(clamp(value, -1.0f, 1.0f));
                break;

            standardBankSetParameters()
        }
    }

    AUValue getParameter(AUParameterAddress address) {
        switch (address) {
            case phaseDistortionAddress:
                return phaseDistortionRamper.getUIValue();
            standardBankGetParameters()
        }
    }

    void startRamp(AUParameterAddress address, AUValue value, AUAudioFrameCount duration) override {
        switch (address) {
                
            case phaseDistortionAddress:
                phaseDistortionRamper.startRamp(clamp(value, -1.0f, 1.0f), duration);
                break;
            standardBankStartRamps()
        }
    }
    
    standardHandleMIDI()

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {

        float* outL = (float*)outBufferListPtr->mBuffers[0].mData + bufferOffset;
        float* outR = (float*)outBufferListPtr->mBuffers[1].mData + bufferOffset;

        phaseDistortion = double(phaseDistortionRamper.getAndStep());
        standardBankGetAndSteps()
        
        for (AUAudioFrameCount i = 0; i < frameCount; ++i) {
            outL[i] = 0.0f;
            outR[i] = 0.0f;
        }
        
        NoteState* noteState = playingNotes;
        while (noteState) {
            noteState->run(frameCount, outL, outR);
            noteState = noteState->next;
        }

        
        for (AUAudioFrameCount i = 0; i < frameCount; ++i) {
            outL[i] *= .5f;
            outR[i] *= .5f;
        }
    }

    // MARK: Member Variables

private:
    std::vector<NoteState> noteStates;

    sp_ftbl *ftbl;
    UInt32 ftbl_size = 4096;
    
    float phaseDistortion = 0.0;

public:
    NoteState* playingNotes = nullptr;

    ParameterRamper phaseDistortionRamper = 0.0;
};

