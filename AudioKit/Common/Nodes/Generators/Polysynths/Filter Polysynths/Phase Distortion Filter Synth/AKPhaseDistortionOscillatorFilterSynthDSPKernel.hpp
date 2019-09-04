//
//  AKPhaseDistortionOscillatorFilterSynthDSPKernel.hpp
//  AudioKit
//
//  Created by Colin Hallett, revision history on Github.
//  Copyright © 2019 AudioKit. All rights reserved.
//

#pragma once

#import "AKFilterSynthDSPKernel.hpp"

class AKPhaseDistortionOscillatorFilterSynthDSPKernel : public AKFilterSynthDSPKernel, public AKOutputBuffered {
protected:
    // MARK: Types
    struct NoteState  : public AKFilterSynthDSPKernel::NoteState {
        
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
            auto filterSynthKernel = (AKPhaseDistortionOscillatorFilterSynthDSPKernel*)kernel;
            
            sp_adsr_init(kernel->getSpData(), adsr);
            sp_tabread_init(kernel->getSpData(), tab, filterSynthKernel->ftbl, 1);

            sp_pdhalf_init(kernel->getSpData(), pdhalf);
            sp_phasor_init(kernel->getSpData(), phs, 0);

            phs->freq = 0;
            
            sp_adsr_init(kernel->getSpData(), filterEnv);
            sp_moogladder_init(kernel->getSpData(), filter);
            filter->freq = 22050.0;
            filter->res = 0.0;
        }

        void noteOn(int noteNumber, int velocity, float frequency) override {
            AKFilterSynthDSPKernel::NoteState::noteOn(noteNumber, velocity, frequency);
            
            if (velocity != 0) {
                phs->freq = frequency;
                velocityAmp = (float)pow2(velocity / 127.);
            }
        }

        void run(int frameCount, float *outL, float *outR) override
        {
            auto filterSynthKernel = (AKPhaseDistortionOscillatorFilterSynthDSPKernel*)kernel;
            
            float originalFrequency = phs->freq;
            phs->freq *= powf(2, kernel->pitchBend / 12.0);
            phs->freq = clamp(phs->freq, 0.0f, 22050.0f);
            float bentFrequency = phs->freq;

            pdhalf->amount = filterSynthKernel->phaseDistortion;

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

                float xf = 0;
                float filterDepth = kernel->filterLFODepth;
                float filterRate = sinf((kernel->currentRunningIndex + frameIndex) * 2 * 2 * M_PI * kernel->filterLFORate / kernel->getSampleRate());
                
                float filterFreq = clamp(sff * powf(2, filterDepth * filterRate), 0.0f, 22050.0f);
                sp_adsr_compute(kernel->getSpData(), filterEnv, &internalGate, &filterAmp);
                filterAmp = filterAmp * filterStrength;
                filter->freq = filterFreq + ((22050.0f - filterFreq) * filterAmp);
                
                filter->freq = clamp(filter->freq, 0.0f, 22050.0f);
                sp_moogladder_compute(kernel->getSpData(), filter, &temp, &xf);
                
                *outL++ += amp * xf;
                *outR++ += amp * xf;

            }
            phs->freq = originalFrequency;
            if (stage == stageRelease && amp < 0.00001) {
                clear();
                remove();
            }
        }

    };

public:
    enum FilterSynthAddresses {
        phaseDistortionAddress = numberOfFilterSynthEnumElements,
    };

    // MARK: Member Functions
public:

    AKPhaseDistortionOscillatorFilterSynthDSPKernel() {
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
        AKFilterSynthDSPKernel::reset();
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
                AKFilterSynthDSPKernel::setParameter(address, value);
                break;
        }
    }

    AUValue getParameter(AUParameterAddress address) {
        switch (address) {
            case phaseDistortionAddress:
                return phaseDistortionRamper.getUIValue();
            default:
                return AKFilterSynthDSPKernel::getParameter(address);
        }
    }

    void startRamp(AUParameterAddress address, AUValue value, AUAudioFrameCount duration) override {
        switch (address) {
            case phaseDistortionAddress:
                phaseDistortionRamper.startRamp(clamp(value, -1.0f, 1.0f), duration);
                break;
            default:
                AKFilterSynthDSPKernel::startRamp(address, value, duration);
                break;
        }
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {

        float *outL = (float *)outBufferListPtr->mBuffers[0].mData + bufferOffset;
        float *outR = (float *)outBufferListPtr->mBuffers[1].mData + bufferOffset;

        phaseDistortion = double(phaseDistortionRamper.getAndStep());
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
    float phaseDistortion = 0.0;

public:
    ParameterRamper phaseDistortionRamper = 0.0;
};
