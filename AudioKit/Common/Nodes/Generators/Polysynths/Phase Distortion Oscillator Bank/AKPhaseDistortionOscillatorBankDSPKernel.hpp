//
//  AKPhaseDistortionOscillatorBankDSPKernel.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once

#import "AKBankDSPKernel.hpp"

class AKPhaseDistortionOscillatorBankDSPKernel : public AKBankDSPKernel, public AKOutputBuffered {
protected:
    // MARK: Types
    struct NoteState  : public AKBankDSPKernel::NoteState {
        
        float velocityAmp = 0;
        
        sp_tabread *tab;
        sp_phasor *phs;
        sp_pdhalf *pdhalf;
        
        NoteState() {
            sp_tabread_create(&tab);
            sp_phasor_create(&phs);
            sp_pdhalf_create(&pdhalf);
        }
        
        virtual ~NoteState() {
            sp_tabread_destroy(&tab);
            sp_phasor_destroy(&phs);
            sp_pdhalf_destroy(&pdhalf);
        }
        
        void init() override {
            auto bankKernel = (AKPhaseDistortionOscillatorBankDSPKernel*)kernel;
            
            sp_adsr_init(kernel->getSpData(), adsr);
            sp_tabread_init(kernel->getSpData(), tab, bankKernel->ftbl, 1);
            
            sp_pdhalf_init(kernel->getSpData(), pdhalf);
            sp_phasor_init(kernel->getSpData(), phs, 0);
            
            phs->freq = 0;
        }
        
        void noteOn(int noteNumber, int velocity, float frequency) override {
            AKBankDSPKernel::NoteState::noteOn(noteNumber, velocity, frequency);
            
            if (velocity != 0) {
                phs->freq = frequency;
                velocityAmp = (float)pow2(velocity / 127.);
            }
        }
        
        void run(int frameCount, float *outL, float *outR) override
        {
            auto bankKernel = (AKPhaseDistortionOscillatorBankDSPKernel*)kernel;
            
            float originalFrequency = phs->freq;
            phs->freq *= powf(2, kernel->pitchBend / 12.0);
            phs->freq = clamp(phs->freq, 0.0f, 22050.0f);
            float bentFrequency = phs->freq;
            
            pdhalf->amount = bankKernel->phaseDistortion;
            
            adsr->atk = (float)kernel->attackDuration;
            adsr->dec = (float)kernel->decayDuration;
            adsr->sus = (float)kernel->sustainLevel;
            adsr->rel = (float)kernel->releaseDuration;
            
            for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
                float temp = 0;
                float pd = 0;
                float ph = 0;
                float depth = kernel->vibratoDepth / 12.0;
                float variation = sinf((kernel->currentRunningIndex + frameIndex) * 2 * 2 * M_PI * kernel->vibratoRate / kernel->getSampleRate());
                phs->freq = bentFrequency * powf(2, depth * variation);
                
                sp_adsr_compute(kernel->getSpData(), adsr, &internalGate, &amp);
                
                sp_phasor_compute(kernel->getSpData(), phs, NULL, &ph);
                sp_pdhalf_compute(kernel->getSpData(), pdhalf, &ph, &pd);
                tab->index = pd;
                sp_tabread_compute(kernel->getSpData(), tab, NULL, &temp);
                
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
    
public:
    enum BankAddresses {
        phaseDistortionAddress = numberOfBankEnumElements,
    };
    
    // MARK: Member Functions
public:
    
    AKPhaseDistortionOscillatorBankDSPKernel() {
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
    
    void reset() override {
        AKBankDSPKernel::reset();
        phaseDistortionRamper.reset();
    }
    
    void setPhaseDistortion(float value) {
        phaseDistortion = clamp(value, -1.0f, 1.0f);
        phaseDistortionRamper.setImmediate(phaseDistortion);
    }
    
    void setParameter(AUParameterAddress address, AUValue value) {
        switch (address) {
            case phaseDistortionAddress:
                phaseDistortionRamper.setUIValue(clamp(value, -1.0f, 1.0f));
                break;
            default:
                AKBankDSPKernel::setParameter(address, value);
                break;
        }
    }
    
    AUValue getParameter(AUParameterAddress address) {
        switch (address) {
            case phaseDistortionAddress:
                return phaseDistortionRamper.getUIValue();
            default:
                return AKBankDSPKernel::getParameter(address);
        }
    }
    
    void startRamp(AUParameterAddress address, AUValue value, AUAudioFrameCount duration) override {
        switch (address) {
            case phaseDistortionAddress:
                phaseDistortionRamper.startRamp(clamp(value, -1.0f, 1.0f), duration);
                break;
            default:
                AKBankDSPKernel::startRamp(address, value, duration);
                break;
        }
    }
    
    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {
        
        float *outL = (float *)outBufferListPtr->mBuffers[0].mData + bufferOffset;
        float *outR = (float *)outBufferListPtr->mBuffers[1].mData + bufferOffset;
        
        phaseDistortion = double(phaseDistortionRamper.getAndStep());
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
    float phaseDistortion = 0.0;
    
public:
    ParameterRamper phaseDistortionRamper = 0.0;
};
