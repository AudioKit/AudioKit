//
//  AKMorphingOscillatorBankDSPKernel.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#ifdef __cplusplus
#pragma once

#import "AKBankDSPKernel.hpp"

class AKMorphingOscillatorBankDSPKernel : public AKBankDSPKernel, public AKOutputBuffered {
protected:
    // MARK: Types
    
    struct NoteState  : public AKBankDSPKernel::NoteState {
        
        sp_oscmorph *osc;
        
        NoteState() {
            sp_oscmorph_create(&osc);
        }
        
        virtual ~NoteState() {
            sp_oscmorph_destroy(&osc);
        }
        
        void init() override {
            AKMorphingOscillatorBankDSPKernel *bankKernel = (AKMorphingOscillatorBankDSPKernel*)kernel;
            
            sp_adsr_init(kernel->getSpData(), adsr);
            sp_oscmorph_init(kernel->getSpData(), osc, bankKernel->ft_array, 4, 0);
            osc->freq = 0;
            osc->amp = 0;
            osc->wtpos = 0;
        }
        
        void noteOn(int noteNumber, int velocity, float frequency) override
        {
            AKBankDSPKernel::NoteState::noteOn(noteNumber, velocity, frequency);
            
            if (velocity != 0) {
                osc->freq = frequency;
                osc->amp = (float)pow2(velocity / 127.);
            }
        }
        
        void run(int frameCount, float *outL, float *outR) override
        {
            AKMorphingOscillatorBankDSPKernel *bankKernel = (AKMorphingOscillatorBankDSPKernel*)kernel;
            
            float originalFrequency = osc->freq;
            osc->freq *= powf(2, kernel->pitchBend / 12.0);
            osc->freq = clamp(osc->freq, 0.0f, 22050.0f);
            float bentFrequency = osc->freq;
            osc->wtpos = bankKernel->index / 3.0;
            
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
                sp_oscmorph_compute(kernel->getSpData(), osc, nil, &x);
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
    
public:
    enum BankAddresses {
        indexAddress = numberOfBankEnumElements,
    };
    
    // MARK: Member Functions
public:
    
    AKMorphingOscillatorBankDSPKernel() {
        noteStates.resize(128);
        for (auto& ns : noteStates)
        {
            ns.reset(new NoteState);
            ns->kernel = this;
        }
        reset();
    }
    
    void setupWaveform(uint32_t waveform, uint32_t size) {
        tbl_size = size;
        sp_ftbl_create(sp, &ft_array[waveform], tbl_size);
    }
    
    void setWaveformValue(uint32_t waveform, uint32_t index, float value) {
        ft_array[waveform]->tbl[index] = value;
    }
    
    void setIndex(float value) {
        index = clamp(value, 0.0f, 3.0f);
        indexRamper.setUIValue(index);
    }
    
    void reset() override {
        AKBankDSPKernel::reset();
        indexRamper.reset();
    }
    
    void setParameter(AUParameterAddress address, AUValue value) {
        switch (address) {
            case indexAddress:
                indexRamper.setUIValue(clamp(value, 0.0f, 3.0f));
                break;
            default:
                AKBankDSPKernel::setParameter(address, value);
                break;
        }
    }
    
    AUValue getParameter(AUParameterAddress address) {
        switch (address) {
            case indexAddress:
                return indexRamper.getUIValue();
            default:
                return AKBankDSPKernel::getParameter(address);
        }
    }
    
    void startRamp(AUParameterAddress address, AUValue value, AUAudioFrameCount duration) override {
        switch (address) {
            case indexAddress:
                indexRamper.startRamp(clamp(value, 0.0f, 3.0f), duration);
                break;
            default:
                AKBankDSPKernel::startRamp(address, value, duration);
                break;
        }
    }
    
    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {
        
        float *outL = (float *)outBufferListPtr->mBuffers[0].mData + bufferOffset;
        float *outR = (float *)outBufferListPtr->mBuffers[1].mData + bufferOffset;
        
        standardBankGetAndSteps();
        index = double(indexRamper.getAndStep());
        
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
    sp_ftbl *ft_array[4];
    UInt32 tbl_size = 4096;
    float index = 0;
    
public:
    ParameterRamper indexRamper = 0.0;
};

#endif
