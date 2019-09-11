//
//  AKPWMOscillatorFilterSynthDSPKernel.hpp
//  AudioKit
//
//  Created by Colin Hallett, revision history on Github.
//  Copyright © 2019 AudioKit. All rights reserved.
//

#ifdef __cplusplus
#pragma once

#import "AKFilterSynthDSPKernel.hpp"

class AKPWMOscillatorFilterSynthDSPKernel : public AKFilterSynthDSPKernel, public AKOutputBuffered {
protected:
    // MARK: Types
    
    struct NoteState  : public AKFilterSynthDSPKernel::NoteState {

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
            
            sp_adsr_init(kernel->getSpData(), filterEnv);
            sp_moogladder_init(kernel->getSpData(), filter);
            filter->freq = 22050.0;
            filter->res = 0.0;
        }

        void noteOn(int noteNumber, int velocity, float frequency) override {
            AKFilterSynthDSPKernel::NoteState::noteOn(noteNumber, velocity, frequency);

            if (velocity != 0) {
                *blsquare->freq = frequency;
                *blsquare->amp = (float)pow2(velocity / 127.);
            }
        }

        void run(int frameCount, float *outL, float *outR) override
        {
            auto filterSynthKernel = (AKPWMOscillatorFilterSynthDSPKernel*)kernel;
            
            float originalFrequency = *blsquare->freq;
            *blsquare->freq *= powf(2, kernel->pitchBend / 12.0);
            *blsquare->freq = clamp(*blsquare->freq, 0.0f, 22050.0f);
            float bentFrequency = *blsquare->freq;

            *blsquare->width = filterSynthKernel->pulseWidth;

            adsr->atk = (float)kernel->attackDuration;
            adsr->dec = (float)kernel->decayDuration;
            adsr->sus = (float)kernel->sustainLevel;
            adsr->rel = (float)kernel->releaseDuration;
            
            float sff = (float)kernel->filterCutoffFrequency;
            float sfr = (float)kernel->filterResonance;
            float filterStrength = kernel->filterEnvelopeStrength;
            
            filter->freq = sff;
            filter->res = sfr;
            
            filterEnv->atk = (float)kernel->filterAttackDuration;
            filterEnv->dec = (float)kernel->filterDecayDuration;
            filterEnv->sus = (float)kernel->filterSustainLevel;
            filterEnv->rel = (float)kernel->filterReleaseDuration;

            for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
                float x = 0;
                float depth = kernel->vibratoDepth / 12.0;
                float variation = sinf((kernel->currentRunningIndex + frameIndex) * 2 * 2 * M_PI * kernel->vibratoRate / kernel->getSampleRate());
                *blsquare->freq = bentFrequency * powf(2, depth * variation);
                sp_adsr_compute(kernel->getSpData(), adsr, &internalGate, &amp);
                sp_blsquare_compute(kernel->getSpData(), blsquare, nil, &x);
                
                float xf = 0;
                float filterDepth = kernel->filterLFODepth;
                float filterRate = sinf((kernel->currentRunningIndex + frameIndex) * 2 * 2 * M_PI * kernel->filterLFORate / kernel->getSampleRate());
                
                float filterFreq = clamp(sff * powf(2, filterDepth * filterRate), 0.0f, 22050.0f);
                sp_adsr_compute(kernel->getSpData(), filterEnv, &internalGate, &filterAmp);
                filterAmp = filterAmp * filterStrength;
                filter->freq = filterFreq + ((22050.0f - filterFreq) * filterAmp);
                
                filter->freq = clamp(filter->freq, 0.0f, 22050.0f);
                sp_moogladder_compute(kernel->getSpData(), filter, &x, &xf);
                
                *outL++ += amp * xf;
                *outR++ += amp * xf;
            }
            *blsquare->freq = originalFrequency;
            if (stage == stageRelease && amp < 0.00001) {
                clear();
                remove();
            }
        }

    };

public:
    enum FilterSynthAddresses {
        pulseWidthAddress = numberOfFilterSynthEnumElements,
    };

    // MARK: Member Functions
public:

    AKPWMOscillatorFilterSynthDSPKernel() {
        noteStates.resize(128);
        for (auto& ns : noteStates)
        {
            ns.reset(new NoteState);
            ns->kernel = this;
        }
    }

    void init(int channelCount, double sampleRate) override {
        AKFilterSynthDSPKernel::init(channelCount, sampleRate);
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
                AKFilterSynthDSPKernel::setParameter(address, value);
                break;
        }
    }

    AUValue getParameter(AUParameterAddress address) {
        switch (address) {
            case pulseWidthAddress:
                return pulseWidthRamper.getUIValue();
            default:
                return AKFilterSynthDSPKernel::getParameter(address);
        }
    }

    void startRamp(AUParameterAddress address, AUValue value, AUAudioFrameCount duration) override {
        switch (address) {
            case pulseWidthAddress:
                pulseWidthRamper.startRamp(clamp(value, 0.0f, 1.0f), duration);
                break;
            default:
                AKFilterSynthDSPKernel::startRamp(address, value, duration);
                break;
        }
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {

        float *outL = (float *)outBufferListPtr->mBuffers[0].mData + bufferOffset;
        float *outR = (float *)outBufferListPtr->mBuffers[1].mData + bufferOffset;

        pulseWidth = double(pulseWidthRamper.getAndStep());
        standardFilterSynthGetAndSteps();

        AKFilterSynthDSPKernel::NoteState *noteState = playingNotes;
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

