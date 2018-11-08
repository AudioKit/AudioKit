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
public:
    // MARK: Types
    
    enum {
        standardBankEnumElements(),
        pulseWidthAddress = numberOfBankEnumElements
    };
    
    struct NoteState {
        NoteState *next;
        NoteState *prev;
        AKPWMOscillatorBankDSPKernel *kernel;

        enum { stageOff, stageOn, stageRelease };
        int stage = stageOff;

        float internalGate = 0;
        float amp = 0;

        sp_adsr *adsr;
        sp_blsquare *blsquare;

        void init() {
            sp_adsr_create(&adsr);
            sp_adsr_init(kernel->sp, adsr);
            sp_blsquare_create(&blsquare);
            sp_blsquare_init(kernel->sp, blsquare);
            *blsquare->freq = 0;
            *blsquare->amp = 0;
            *blsquare->width = 0.5;
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

            sp_blsquare_destroy(&blsquare);
        }

        void add() {
            init();
            prev = nullptr;
            next = kernel->playingNotes;
            if (next) next->prev = this;
            kernel->playingNotes = this;
            ++kernel->playingNotesCount;
        }

        void noteOn(int noteNumber, int velocity) {
            noteOn(noteNumber, velocity, (float)noteToHz(noteNumber));
        }

        void noteOn(int noteNumber, int velocity, float frequency) {
            if (velocity == 0) {
                if (stage == stageOn) {
                    stage = stageRelease;
                    internalGate = 0;
                }
            } else {
                if (stage == stageOff) { add(); }
                *blsquare->freq = frequency;
                *blsquare->amp = (float)pow2(velocity / 127.);
                stage = stageOn;
                internalGate = 1;
            }
        }


        void run(int frameCount, float *outL, float *outR)
        {
            float originalFrequency = *blsquare->freq;
            *blsquare->freq *= powf(2, kernel->pitchBend / 12.0);
            *blsquare->freq = clamp(*blsquare->freq, 0.0f, 22050.0f);
            float bentFrequency = *blsquare->freq;

            *blsquare->width = kernel->pulseWidth;

            adsr->atk = (float)kernel->attackDuration;
            adsr->dec = (float)kernel->decayDuration;
            adsr->sus = (float)kernel->sustainLevel;
            adsr->rel = (float)kernel->releaseDuration;

            for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
                float x = 0;
                float depth = kernel->vibratoDepth / 12.0;
                float variation = sinf((kernel->currentRunningIndex + frameIndex) * 2 * 2 * M_PI * kernel->vibratoRate / kernel->sampleRate);
                *blsquare->freq = bentFrequency * powf(2, depth * variation);
                sp_adsr_compute(kernel->sp, adsr, &internalGate, &amp);
                sp_blsquare_compute(kernel->sp, blsquare, nil, &x);
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

    // MARK: Member Functions

    AKPWMOscillatorBankDSPKernel() {
        noteStates.resize(128);
        for (NoteState& state : noteStates) {
            state.kernel = this;
        }
    }

    void init(int _channels, double _sampleRate) override {
        AKBankDSPKernel::init(_channels, _sampleRate);
        pulseWidthRamper.init();
    }

    void reset() {
        for (NoteState& state : noteStates) {
            state.clear();
        }
        playingNotes = nullptr;
        pulseWidthRamper.reset();
        AKBankDSPKernel::reset();
    }

    standardBankKernelFunctions()

    void setPulseWidth(float value) {
        pulseWidth = clamp(value, 0.0f, 1.0f);
        pulseWidthRamper.setImmediate(pulseWidth);
    }

    void setParameter(AUParameterAddress address, AUValue value) {
        switch (address) {

            case pulseWidthAddress:
                pulseWidthRamper.setUIValue(clamp(value, 0.0f, 1.0f));
                break;
                standardBankSetParameters()
        }
    }

    AUValue getParameter(AUParameterAddress address) {
        switch (address) {

            case pulseWidthAddress:
                return pulseWidthRamper.getUIValue();
                standardBankGetParameters()
        }
    }

    void startRamp(AUParameterAddress address, AUValue value, AUAudioFrameCount duration) override {
        switch (address) {

            case pulseWidthAddress:
                pulseWidthRamper.startRamp(clamp(value, 0.0f, 1.0f), duration);
                break;
                standardBankStartRamps()
        }
    }

    standardHandleMIDI()

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {

        float *outL = (float *)outBufferListPtr->mBuffers[0].mData + bufferOffset;
        float *outR = (float *)outBufferListPtr->mBuffers[1].mData + bufferOffset;

        pulseWidth = double(pulseWidthRamper.getAndStep());
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

    float pulseWidth = 0.5;

public:
    NoteState *playingNotes = nullptr;

    ParameterRamper pulseWidthRamper = 0.5;
};

#endif

