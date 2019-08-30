//
//  AKOscillatorFilterSynthDSPKernel.hpp
//  AudioKit
//
//  Created by Colin Hallett, revision history on Github.
//  Copyright © 2019 AudioKit. All rights reserved.
//

#pragma once

#import "AKFilterSynthDSPKernel.hpp"

class AKOscillatorFilterSynthDSPKernel : public AKFilterSynthDSPKernel, public AKOutputBuffered {
protected:
    // MARK: Types
    struct NoteState  : public AKFilterSynthDSPKernel::NoteState {

        sp_osc *osc;

        NoteState() {
            sp_osc_create(&osc);
        }
        
        virtual ~NoteState() {
            sp_osc_destroy(&osc);
        }
        
        void init() override {
            AKOscillatorFilterSynthDSPKernel *filterSynthKernel = (AKOscillatorFilterSynthDSPKernel*)kernel;
            
            sp_adsr_init(kernel->getSpData(), adsr);
            sp_osc_init(kernel->getSpData(), osc, filterSynthKernel->ftbl, 0);
            osc->freq = 0;
            osc->amp = 0;
            
            sp_adsr_init(kernel->getSpData(), filterEnv);
            sp_moogladder_init(kernel->getSpData(), filter);
            filter->freq = 22050.0;
            filter->res = 0.0;
        }

        void noteOn(int noteNumber, int velocity, float frequency) override
        {
            AKFilterSynthDSPKernel::NoteState::noteOn(noteNumber, velocity, frequency);
            
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
                osc->freq = bentFrequency * powf(2, depth * variation);

                sp_adsr_compute(kernel->getSpData(), adsr, &internalGate, &amp);
                sp_osc_compute(kernel->getSpData(), osc, nil, &x);
                
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
            osc->freq = originalFrequency;
            if (stage == stageRelease && amp < 0.00001) {
                clear();
                remove();
            }
        }

    };

    // MARK: Member Functions
public:

    AKOscillatorFilterSynthDSPKernel() {
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
};
