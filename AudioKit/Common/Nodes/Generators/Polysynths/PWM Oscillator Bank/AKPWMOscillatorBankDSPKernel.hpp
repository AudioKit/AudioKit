//
//  AKPWMOscillatorBankDSPKernel.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#ifdef __cplusplus
#pragma once

#import "AKBankDSPKernel.hpp"

class AKPWMOscillatorBankDSPKernel : public AKBankDSPKernel, public AKOutputBuffered {
protected:
    // MARK: Types
    
    struct NoteState  : public AKBankDSPKernel::NoteState {
        
        sp_blsquare *blsquare;
        
        NoteState() {
            sp_blsquare_create(&blsquare);
        }
        
        virtual ~NoteState() {
            sp_blsquare_destroy(&blsquare);
        }
        
        void init() override {
            sp_adsr_create(&adsr);
            sp_adsr_init(kernel->getSpData(), adsr);
            sp_blsquare_init(kernel->getSpData(), blsquare);
            *blsquare->freq = 0;
            *blsquare->amp = 0;
            *blsquare->width = 0.5;
        }
        
        void noteOn(int noteNumber, int velocity, float frequency) override {
            AKBankDSPKernel::NoteState::noteOn(noteNumber, velocity, frequency);
            
            if (velocity != 0) {
                *blsquare->freq = frequency;
                *blsquare->amp = (float)pow2(velocity / 127.);
            }
        }
        
        void run(int frameCount, float *outL, float *outR) override
        {
            auto bankKernel = (AKPWMOscillatorBankDSPKernel*)kernel;
            
            float originalFrequency = *blsquare->freq;
            *blsquare->freq *= powf(2, kernel->pitchBend / 12.0);
            *blsquare->freq = clamp(*blsquare->freq, 0.0f, 22050.0f);
            float bentFrequency = *blsquare->freq;
            
            *blsquare->width = bankKernel->pulseWidth;
            
            adsr->atk = (float)kernel->attackDuration;
            adsr->dec = (float)kernel->decayDuration;
            adsr->sus = (float)kernel->sustainLevel;
            adsr->rel = (float)kernel->releaseDuration;
            
            for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
                float x = 0;
                float depth = kernel->vibratoDepth / 12.0;
                float variation = sinf((kernel->currentRunningIndex + frameIndex) * 2 * 2 * M_PI * kernel->vibratoRate / kernel->getSampleRate());
                *blsquare->freq = bentFrequency * powf(2, depth * variation);
                sp_adsr_compute(kernel->getSpData(), adsr, &internalGate, &amp);
                sp_blsquare_compute(kernel->getSpData(), blsquare, nil, &x);
                *outL++ += amp * x;
                *outR++ += amp * x;
                
            }
            *blsquare->freq = originalFrequency;
            if (stage == stageRelease && amp < 0.00001) {
                clear();
                remove();
            }
        }
        
    };
    
public:
    enum BankAddresses {
        pulseWidthAddress = numberOfBankEnumElements,
    };
    
    // MARK: Member Functions
public:
    
    AKPWMOscillatorBankDSPKernel() {
        noteStates.resize(128);
        for (auto& ns : noteStates)
        {
            ns.reset(new NoteState);
            ns->kernel = this;
        }
    }
    
    void init(int channelCount, double sampleRate) override {
        AKBankDSPKernel::init(channelCount, sampleRate);
        pulseWidthRamper.init();
    }
    
    void reset() override {
        pulseWidthRamper.reset();
    }
    
    void setPulseWidth(float value) {
        pulseWidth = clamp(value, 0.0f, 1.0f);
        pulseWidthRamper.setImmediate(pulseWidth);
    }
    
    void setParameter(AUParameterAddress address, AUValue value) {
        switch (address) {
            case pulseWidthAddress:
                pulseWidthRamper.setUIValue(clamp(value, 0.0f, 1.0f));
                break;
            default:
                AKBankDSPKernel::setParameter(address, value);
                break;
        }
    }
    
    AUValue getParameter(AUParameterAddress address) {
        switch (address) {
            case pulseWidthAddress:
                return pulseWidthRamper.getUIValue();
            default:
                return AKBankDSPKernel::getParameter(address);
        }
    }
    
    void startRamp(AUParameterAddress address, AUValue value, AUAudioFrameCount duration) override {
        switch (address) {
            case pulseWidthAddress:
                pulseWidthRamper.startRamp(clamp(value, 0.0f, 1.0f), duration);
                break;
            default:
                AKBankDSPKernel::startRamp(address, value, duration);
                break;
        }
    }
    
    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {
        
        float *outL = (float *)outBufferListPtr->mBuffers[0].mData + bufferOffset;
        float *outR = (float *)outBufferListPtr->mBuffers[1].mData + bufferOffset;
        
        pulseWidth = double(pulseWidthRamper.getAndStep());
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
    float pulseWidth = 0.5;
    
public:
    ParameterRamper pulseWidthRamper = 0.5;
};

#endif

