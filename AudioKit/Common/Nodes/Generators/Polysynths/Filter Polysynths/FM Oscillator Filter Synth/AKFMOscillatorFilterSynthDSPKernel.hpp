//
//  AKFMOscillatorFilterSynthDSPKernel.hpp
//  AudioKit
//
//  Created by Colin Hallett, revision history on Github.
//  Copyright © 2019 AudioKit. All rights reserved.
//

#pragma once

#import "AKFilterSynthDSPKernel.hpp"

class AKFMOscillatorFilterSynthDSPKernel : public AKFilterSynthDSPKernel, public AKOutputBuffered {
protected:
    // MARK: Types
    struct NoteState : public AKFilterSynthDSPKernel::NoteState {
        
        sp_fosc *fosc;
        
        NoteState() {
            sp_fosc_create(&fosc);
        }

        virtual ~NoteState() {
            sp_fosc_destroy(&fosc);
        }
        
        void init() override {
            AKFMOscillatorFilterSynthDSPKernel *filterSynthKernel = (AKFMOscillatorFilterSynthDSPKernel*)kernel;

            sp_adsr_init(kernel->getSpData(), adsr);
            sp_fosc_init(kernel->getSpData(), fosc, filterSynthKernel->ftbl);
            fosc->freq = 0;
            fosc->amp = 0;
            
            sp_adsr_init(kernel->getSpData(), filterEnv);
            sp_moogladder_init(kernel->getSpData(), filter);
            filter->freq = 22050.0;
            filter->res = 0.0;
        }

        void noteOn(int noteNumber, int velocity, float frequency) override
        {
            AKFilterSynthDSPKernel::NoteState::noteOn(noteNumber, velocity, frequency);
            
            if (velocity != 0) {
                fosc->freq = frequency;
                fosc->amp = (float)pow2(velocity / 127.);
            }
        }

        void run(int frameCount, float *outL, float *outR) override
        {
            AKFMOscillatorFilterSynthDSPKernel *filterSynthKernel = (AKFMOscillatorFilterSynthDSPKernel*)kernel;
            
            float originalFrequency = fosc->freq;
            fosc->freq *= powf(2, kernel->pitchBend / 12.0);
            fosc->freq = clamp(fosc->freq, 0.0f, 22050.0f);
            float bentFrequency = fosc->freq;

            fosc->car = filterSynthKernel->carrierMultiplier;
            fosc->mod = filterSynthKernel->modulatingMultiplier;
            fosc->indx = filterSynthKernel->modulationIndex;

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
                fosc->freq = bentFrequency * powf(2, depth * variation);
                sp_adsr_compute(kernel->getSpData(), adsr, &internalGate, &amp);
                sp_fosc_compute(kernel->getSpData(), fosc, nil, &x);
                
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
            fosc->freq = originalFrequency;
            if (stage == stageRelease && amp < 0.00001) {
                clear();
                remove();
            }
        }

    };

public:
    enum FilterSynthAddresses {
        carrierMultiplierAddress = numberOfFilterSynthEnumElements,
        modulatingMultiplierAddress,
        modulationIndexAddress
    };

    // MARK: Member Functions
public:

    AKFMOscillatorFilterSynthDSPKernel() {
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
                AKFilterSynthDSPKernel::setParameter(address, value);
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
                return AKFilterSynthDSPKernel::getParameter(address);
                
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
                AKFilterSynthDSPKernel::startRamp(address, value, duration);
                break;
                
        }
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {

        float *outL = (float *)outBufferListPtr->mBuffers[0].mData + bufferOffset;
        float *outR = (float *)outBufferListPtr->mBuffers[1].mData + bufferOffset;

        carrierMultiplier = double(carrierMultiplierRamper.getAndStep());
        modulatingMultiplier = double(modulatingMultiplierRamper.getAndStep());
        modulationIndex = double(modulationIndexRamper.getAndStep());
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
