//
//  AKOscillatorBankDSPKernel.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once

#import "AKBankDSPKernel.hpp"

class AKOscillatorBankDSPKernel : public AKBankDSPKernel, public AKOutputBuffered {
protected:
    // MARK: Types
    struct NoteState  : public AKBankDSPKernel::NoteState {
        
        sp_osc *osc;
        
        NoteState() {
            sp_osc_create(&osc);
        }
        
        virtual ~NoteState() {
            sp_osc_destroy(&osc);
        }
        
        void init() override {
            AKOscillatorBankDSPKernel *bankKernel = (AKOscillatorBankDSPKernel*)kernel;
            
            sp_adsr_init(kernel->getSpData(), adsr);
            sp_osc_init(kernel->getSpData(), osc, bankKernel->ftbl, 0);
            osc->freq = 0;
            osc->amp = 0;
        }
        
        void noteOn(int noteNumber, int velocity, float frequency) override
        {
            AKBankDSPKernel::NoteState::noteOn(noteNumber, velocity, frequency);
            
            if (velocity != 0) {
                osc->freq = (float)frequency;
                osc->amp = (float)pow2(velocity / 127.);
            }
        }
        
        void run(int frameCount, float *outL, float *outR) override
        {
            float originalFrequency = osc->freq;
            
            osc->freq *= powf(2, kernel->pitchBend / 12.0);
            osc->freq = clamp(osc->freq, 0.0f, 22050.0f);
            float bentFrequency = osc->freq;
            
            adsr->atk = (float)kernel->attackDuration;
            adsr->dec = (float)kernel->decayDuration;
            adsr->sus = (float)kernel->sustainLevel;
            adsr->rel = (float)kernel->releaseDuration;
            
            for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
                float x = 0;
                float depth = kernel->vibratoDepth / 12.0;
                float variation = sinf((kernel->currentRunningIndex + frameIndex) * 2 * 2 * M_PI * kernel->vibratoRate / kernel->getSampleRate());
                osc->freq = bentFrequency * powf(2, depth * variation);
                
                sp_adsr_compute(kernel->getSpData(), adsr, &internalGate, &amp);
                sp_osc_compute(kernel->getSpData(), osc, nil, &x);
                *outL++ += amp * x;
                *outR++ += amp * x;
                
            }
            osc->freq = originalFrequency;
            if (stage == stageRelease && amp < 0.00001) {
                clear();
                remove();
            }
        }
        
    };
    
    // MARK: Member Functions
public:
    
    AKOscillatorBankDSPKernel() {
        noteStates.resize(128);
        for (auto& ns : noteStates)
        {
            ns.reset(new NoteState);
            ns->kernel = this;
        }
    }
    
    void setupWaveform(uint32_t size) {
        ftbl_size = size;
        sp_ftbl_create(sp, &ftbl, ftbl_size);
    }
    
    void setWaveformValue(uint32_t index, float value) {
        ftbl->tbl[index] = value;
    }
    
    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {
        
        float *outL = (float *)outBufferListPtr->mBuffers[0].mData + bufferOffset;
        float *outR = (float *)outBufferListPtr->mBuffers[1].mData + bufferOffset;
        
        standardBankGetAndSteps();
        
        AKBankDSPKernel::NoteState *noteState = playingNotes;
        while (noteState) {
            noteState->run(frameCount, outL, outR);
            noteState = noteState->next;
        }
        currentRunningIndex += frameCount / 2;
        
        for (AUAudioFrameCount i = 0; i < frameCount; ++i) {
            outL[i] *= .5f;
            outR[i] *= .5f;
        }
    }
    
    // MARK: Member Variables
    
private:
    sp_ftbl *ftbl;
    UInt32 ftbl_size = 4096;
};
