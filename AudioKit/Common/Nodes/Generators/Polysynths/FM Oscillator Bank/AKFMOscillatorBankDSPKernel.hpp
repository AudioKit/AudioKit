//
//  AKFMOscillatorBankDSPKernel.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once

#import "AKBankDSPKernel.hpp"

class AKFMOscillatorBankDSPKernel : public AKBankDSPKernel, public AKOutputBuffered {
protected:
    // MARK: Types
    struct NoteState : public AKBankDSPKernel::NoteState {
        
        sp_fosc *fosc;
        
        NoteState() {
            sp_fosc_create(&fosc);
        }
        
        virtual ~NoteState() {
            sp_fosc_destroy(&fosc);
        }
        
        void init() override {
            AKFMOscillatorBankDSPKernel *bankKernel = (AKFMOscillatorBankDSPKernel*)kernel;
            
            sp_adsr_init(kernel->getSpData(), adsr);
            sp_fosc_init(kernel->getSpData(), fosc, bankKernel->ftbl);
            fosc->freq = 0;
            fosc->amp = 0;
        }
        
        void noteOn(int noteNumber, int velocity, float frequency) override
        {
            AKBankDSPKernel::NoteState::noteOn(noteNumber, velocity, frequency);
            
            if (velocity != 0) {
                fosc->freq = frequency;
                fosc->amp = (float)pow2(velocity / 127.);
            }
        }
        
        void run(int frameCount, float *outL, float *outR) override
        {
            AKFMOscillatorBankDSPKernel *bankKernel = (AKFMOscillatorBankDSPKernel*)kernel;
            
            float originalFrequency = fosc->freq;
            fosc->freq *= powf(2, kernel->pitchBend / 12.0);
            fosc->freq = clamp(fosc->freq, 0.0f, 22050.0f);
            float bentFrequency = fosc->freq;
            
            fosc->car = bankKernel->carrierMultiplier;
            fosc->mod = bankKernel->modulatingMultiplier;
            fosc->indx = bankKernel->modulationIndex;
            
            adsr->atk = (float)kernel->attackDuration;
            adsr->dec = (float)kernel->decayDuration;
            adsr->sus = (float)kernel->sustainLevel;
            adsr->rel = (float)kernel->releaseDuration;
            
            for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
                float x = 0;
                float depth = kernel->vibratoDepth / 12.0;
                float variation = sinf((kernel->currentRunningIndex + frameIndex) * 2 * 2 * M_PI * kernel->vibratoRate / kernel->getSampleRate());
                fosc->freq = bentFrequency * powf(2, depth * variation);
                sp_adsr_compute(kernel->getSpData(), adsr, &internalGate, &amp);
                sp_fosc_compute(kernel->getSpData(), fosc, nil, &x);
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
    
public:
    enum BankAddresses {
        carrierMultiplierAddress = numberOfBankEnumElements,
        modulatingMultiplierAddress,
        modulationIndexAddress
    };
    
    // MARK: Member Functions
public:
    
    AKFMOscillatorBankDSPKernel() {
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
                
            default:
                AKBankDSPKernel::setParameter(address, value);
                break;
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
                
            default:
                return AKBankDSPKernel::getParameter(address);
                
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
                
            default:
                AKBankDSPKernel::startRamp(address, value, duration);
                break;
                
        }
    }
    
    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {
        
        float *outL = (float *)outBufferListPtr->mBuffers[0].mData + bufferOffset;
        float *outR = (float *)outBufferListPtr->mBuffers[1].mData + bufferOffset;
        
        carrierMultiplier = double(carrierMultiplierRamper.getAndStep());
        modulatingMultiplier = double(modulatingMultiplierRamper.getAndStep());
        modulationIndex = double(modulationIndexRamper.getAndStep());
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
    
    float carrierMultiplier = 1.0;
    float modulatingMultiplier = 1;
    float modulationIndex = 1;
    
public:
    ParameterRamper carrierMultiplierRamper = 1.0;
    ParameterRamper modulatingMultiplierRamper = 1;
    ParameterRamper modulationIndexRamper = 1;
};
