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
public:
    // MARK: Types
    enum {
        standardBankEnumElements(),
        indexAddress = numberOfBankEnumElements
    };
    
    struct NoteState {
        NoteState *next;
        NoteState *prev;
        AKMorphingOscillatorBankDSPKernel *kernel;

        enum { stageOff, stageOn, stageRelease };
        int stage = stageOff;

        float internalGate = 0;
        float amp = 0;

        sp_adsr *adsr;
        sp_oscmorph *osc;

        void init() {
            sp_adsr_create(&adsr);
            sp_adsr_init(kernel->sp, adsr);
            sp_oscmorph_create(&osc);
            sp_oscmorph_init(kernel->sp, osc, kernel->ft_array, 4, 0);
            osc->freq = 0;
            osc->amp = 0;
            osc->wtpos = 0;
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

            sp_oscmorph_destroy(&osc);
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
                osc->freq = frequency;
                osc->amp = (float)pow2(velocity / 127.);
                stage = stageOn;
                internalGate = 1;
            }
        }


        void run(int frameCount, float *outL, float *outR)
        {
            float originalFrequency = osc->freq;
            osc->freq *= powf(2, kernel->pitchBend / 12.0);
            osc->freq = clamp(osc->freq, 0.0f, 22050.0f);
            float bentFrequency = osc->freq;
            osc->wtpos = kernel->index / 3.0;

            adsr->atk = (float)kernel->attackDuration;
            adsr->dec = (float)kernel->decayDuration;
            adsr->sus = (float)kernel->sustainLevel;
            adsr->rel = (float)kernel->releaseDuration;

            for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
                float x = 0;
                float depth = kernel->vibratoDepth / 12.0;
                float variation = sinf((kernel->currentRunningIndex + frameIndex) * 2 * 2 * M_PI * kernel->vibratoRate / kernel->sampleRate);
                osc->freq = bentFrequency * powf(2, depth * variation);

                sp_adsr_compute(kernel->sp, adsr, &internalGate, &amp);
                sp_oscmorph_compute(kernel->sp, osc, nil, &x);
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

    AKMorphingOscillatorBankDSPKernel() {
        noteStates.resize(128);
        for (NoteState& state : noteStates) {
            state.kernel = this;
        }
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
    }

    void reset() {
        for (NoteState& state : noteStates) {
            state.clear();
        }
        playingNotes = nullptr;
        indexRamper.reset();
        AKBankDSPKernel::reset();
    }

    standardBankKernelFunctions()

    void setParameter(AUParameterAddress address, AUValue value) {
        switch (address) {
            case indexAddress:
                indexRamper.setUIValue(clamp(value, 0.0f, 3.0f));
                break;
                standardBankSetParameters()
        }
    }

    AUValue getParameter(AUParameterAddress address) {
        switch (address) {
            case indexAddress:
                return indexRamper.getUIValue();
                standardBankGetParameters()
        }
    }

    void startRamp(AUParameterAddress address, AUValue value, AUAudioFrameCount duration) override {
        switch (address) {
            case indexAddress:
                indexRamper.startRamp(clamp(value, 0.0f, 3.0f), duration);
                break;
                standardBankStartRamps()
        }
    }

    standardHandleMIDI()

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {

        float *outL = (float *)outBufferListPtr->mBuffers[0].mData + bufferOffset;
        float *outR = (float *)outBufferListPtr->mBuffers[1].mData + bufferOffset;

        index = double(indexRamper.getAndStep());
        standardBankGetAndSteps()

        NoteState *noteState = playingNotes;
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
    std::vector<NoteState> noteStates;

    sp_ftbl *ft_array[4];
    UInt32 tbl_size = 4096;

    float index = 0;

public:
    NoteState *playingNotes = nullptr;

    ParameterRamper indexRamper = 0.0;
};

#endif

