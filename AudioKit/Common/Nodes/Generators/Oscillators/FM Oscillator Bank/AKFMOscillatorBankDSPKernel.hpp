//
//  AKFMOscillatorBankDSPKernel.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

#pragma once

#import "AKBankDSPKernel.hpp"

enum {
    carrierMultiplierAddress = 0,
    modulatingMultiplierAddress = 1,
    modulationIndexAddress = 2,
    attackDurationAddress = 3,
    decayDurationAddress = 4,
    sustainLevelAddress = 5,
    releaseDurationAddress = 6,
    detuningOffsetAddress = 7,
    detuningMultiplierAddress = 8
};

class AKFMOscillatorBankDSPKernel : public AKBankDSPKernel, public AKOutputBuffered {
public:
    // MARK: Types
    struct NoteState {
        NoteState* next;
        NoteState* prev;
        AKFMOscillatorBankDSPKernel* kernel;
        
        enum { stageOff, stageOn, stageRelease };
        int stage = stageOff;
        
        float internalGate = 0;
        float amp = 0;
        
        sp_adsr *adsr;
        sp_fosc *fosc;
        
        void init() {
            sp_adsr_create(&adsr);
            sp_adsr_init(kernel->sp, adsr);
            sp_fosc_create(&fosc);
            sp_fosc_init(kernel->sp, fosc, kernel->ftbl);
            fosc->freq = 0;
            fosc->amp = 0;
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

            sp_fosc_destroy(&fosc);
            sp_adsr_destroy(&adsr);
        }
        
        void add() {
            init();
            prev = nullptr;
            next = kernel->playingNotes;
            if (next) next->prev = this;
            kernel->playingNotes = this;
            ++kernel->playingNotesCount;
        }
        
        void noteOn(int noteNumber, int velocity)
        {
            noteOn(noteNumber, velocity, (float)noteToHz(noteNumber));
        }
        
        void noteOn(int noteNumber, int velocity, float frequency)
        {
            if (velocity == 0) {
                if (stage == stageOn) {
                    stage = stageRelease;
                    internalGate = 0;
                }
            } else {
                if (stage == stageOff) { add(); }
                fosc->freq = frequency;
                fosc->amp = (float)pow2(velocity / 127.);
                stage = stageOn;
                internalGate = 1;
            }
        }
        
        
        void run(int frameCount, float* outL, float* outR)
        {
            float originalFrequency = fosc->freq;
            fosc->freq *= kernel->detuningMultiplier;
            fosc->freq += kernel->detuningOffset;
            fosc->freq = clamp(fosc->freq, 0.0f, 22050.0f);
            fosc->car = kernel->carrierMultiplier;
            fosc->mod = kernel->modulatingMultiplier;
            fosc->indx = kernel->modulationIndex;
            
            adsr->atk = (float)kernel->attackDuration;
            adsr->dec = (float)kernel->decayDuration;
            adsr->sus = (float)kernel->sustainLevel;
            adsr->rel = (float)kernel->releaseDuration;

            for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
                float x = 0;
                sp_adsr_compute(kernel->sp, adsr, &internalGate, &amp);
                sp_fosc_compute(kernel->sp, fosc, nil, &x);
                *outL++ += amp * x;
                *outR++ += amp * x;
                
            }
            fosc->freq = originalFrequency;
            if (stage == stageRelease && amp < 0.00001) {
                clear();
                remove();
            }
        }
        
    };

    // MARK: Member Functions

    AKFMOscillatorBankDSPKernel() {
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
        AKBankDSPKernel::reset();
    }
    
    void setCarrierMultiplier(float value) {
        carrierMultiplier = clamp(value, 0.0f, 1000.0f);
        carrierMultiplierRamper.setImmediate(carrierMultiplier);
    }
    
    void setModulatingMultiplier(float value) {
        modulatingMultiplier = clamp(value, 0.0f, 1000.0f);
        modulatingMultiplierRamper.setImmediate(modulatingMultiplier);
    }
    
    void setModulationIndex(float value) {
        modulationIndex = clamp(value, 0.0f, 1000.0f);
        modulationIndexRamper.setImmediate(modulationIndex);
    }

    standardBankKernelFunctions()

    void setParameter(AUParameterAddress address, AUValue value) {
        switch (address) {
                
            case carrierMultiplierAddress:
                carrierMultiplierRamper.setUIValue(clamp(value, 0.0f, 1000.0f));
                break;
                
            case modulatingMultiplierAddress:
                modulatingMultiplierRamper.setUIValue(clamp(value, 0.0f, 1000.0f));
                break;
                
            case modulationIndexAddress:
                modulationIndexRamper.setUIValue(clamp(value, 0.0f, 1000.0f));
                break;

            standardBankSetParameters()

        }
    }

    AUValue getParameter(AUParameterAddress address) {
        switch (address) {

            case carrierMultiplierAddress:
                return carrierMultiplierRamper.getUIValue();
                
            case modulatingMultiplierAddress:
                return modulatingMultiplierRamper.getUIValue();
                
            case modulationIndexAddress:
                return modulationIndexRamper.getUIValue();
                
            standardBankGetParameters()
        }
    }

    void startRamp(AUParameterAddress address, AUValue value, AUAudioFrameCount duration) override {
        switch (address) {
                
            case carrierMultiplierAddress:
                carrierMultiplierRamper.startRamp(clamp(value, 0.0f, 1000.0f), duration);
                break;
                
            case modulatingMultiplierAddress:
                modulatingMultiplierRamper.startRamp(clamp(value, 0.0f, 1000.0f), duration);
                break;
                
            case modulationIndexAddress:
                modulationIndexRamper.startRamp(clamp(value, 0.0f, 1000.0f), duration);
                break;
            standardBankStartRamps()
        }
    }

    standardHandleMIDI()

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {

        float* outL = (float*)outBufferListPtr->mBuffers[0].mData + bufferOffset;
        float* outR = (float*)outBufferListPtr->mBuffers[1].mData + bufferOffset;

        carrierMultiplier = double(carrierMultiplierRamper.getAndStep());
        modulatingMultiplier = double(modulatingMultiplierRamper.getAndStep());
        modulationIndex = double(modulationIndexRamper.getAndStep());
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
    
    float carrierMultiplier = 1.0;
    float modulatingMultiplier = 1;
    float modulationIndex = 1;

public:
    NoteState* playingNotes = nullptr;

    ParameterRamper carrierMultiplierRamper = 1.0;
    ParameterRamper modulatingMultiplierRamper = 1;
    ParameterRamper modulationIndexRamper = 1;

};
