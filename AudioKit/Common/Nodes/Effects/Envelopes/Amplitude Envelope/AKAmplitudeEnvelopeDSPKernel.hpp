//
//  AKAmplitudeEnvelopeDSPKernel.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#pragma once

#import "DSPKernel.hpp"
#import "ParameterRamper.hpp"

#import <AudioKit/AudioKit-Swift.h>

extern "C" {
#include "soundpipe.h"
}

enum {
    attackDurationAddress = 0,
    decayDurationAddress = 1,
    sustainLevelAddress = 2,
    releaseDurationAddress = 3
};

class AKAmplitudeEnvelopeDSPKernel : public AKSporthKernel, public AKBuffered {
public:
    // MARK: Member Functions

    AKAmplitudeEnvelopeDSPKernel() {}

    void init(int channelCount, double inSampleRate) {
        AKSporthKernel::init(channelCount, inSampleRate);

        sp_adsr_create(&adsr);

        attackDurationRamper.init();
        decayDurationRamper.init();
        sustainLevelRamper.init();
        releaseDurationRamper.init();
    }

    void start() {
        if (!started) {
            internalGate = 1;
            started = true;
        }
    }

    void stop() {
        if (started) {
            internalGate = 0;
            started = false;
        }
        
    }

    void destroy() {
        sp_adsr_destroy(&adsr);
        AKSporthKernel::destroy();
    }

    void reset() {
        sp_adsr_init(sp, adsr);
        adsr->atk = 0.1;
        adsr->dec = 0.1;
        adsr->sus = 1.0;
        adsr->rel = 0.1;
        resetted = true;
        attackDurationRamper.reset();
        decayDurationRamper.reset();
        sustainLevelRamper.reset();
        releaseDurationRamper.reset();
    }

    void setAttackDuration(float value) {
        attackDuration = clamp(value, 0.0f, 99.0f);
        attackDurationRamper.setImmediate(attackDuration);
    }

    void setDecayDuration(float value) {
        decayDuration = clamp(value, 0.0f, 99.0f);
        decayDurationRamper.setImmediate(decayDuration);
    }

    void setSustainLevel(float value) {
        sustainLevel = clamp(value, 0.0f, 99.0f);
        sustainLevelRamper.setImmediate(sustainLevel);
    }

    void setReleaseDuration(float value) {
        releaseDuration = clamp(value, 0.0f, 99.0f);
        releaseDurationRamper.setImmediate(releaseDuration);
    }


    void setParameter(AUParameterAddress address, AUValue value) {
        switch (address) {
            case attackDurationAddress:
                attackDurationRamper.setUIValue(clamp(value, 0.0f, 99.0f));
                break;

            case decayDurationAddress:
                decayDurationRamper.setUIValue(clamp(value, 0.0f, 99.0f));
                break;

            case sustainLevelAddress:
                sustainLevelRamper.setUIValue(clamp(value, 0.0f, 99.0f));
                break;

            case releaseDurationAddress:
                releaseDurationRamper.setUIValue(clamp(value, 0.0f, 99.0f));
                break;

        }
    }

    AUValue getParameter(AUParameterAddress address) {
        switch (address) {
            case attackDurationAddress:
                return attackDurationRamper.getUIValue();

            case decayDurationAddress:
                return decayDurationRamper.getUIValue();

            case sustainLevelAddress:
                return sustainLevelRamper.getUIValue();

            case releaseDurationAddress:
                return releaseDurationRamper.getUIValue();

            default: return 0.0f;
        }
    }

    void startRamp(AUParameterAddress address, AUValue value, AUAudioFrameCount duration) override {
        switch (address) {
            case attackDurationAddress:
                attackDurationRamper.startRamp(clamp(value, 0.0f, 99.0f), duration);
                break;

            case decayDurationAddress:
                decayDurationRamper.startRamp(clamp(value, 0.0f, 99.0f), duration);
                break;

            case sustainLevelAddress:
                sustainLevelRamper.startRamp(clamp(value, 0.0f, 99.0f), duration);
                break;

            case releaseDurationAddress:
                releaseDurationRamper.startRamp(clamp(value, 0.0f, 99.0f), duration);
                break;

        }
    }


    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {

        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {

            int frameOffset = int(frameIndex + bufferOffset);

            attackDuration = attackDurationRamper.getAndStep();
            adsr->atk = (float)attackDuration;
            decayDuration = decayDurationRamper.getAndStep();
            adsr->dec = (float)decayDuration;
            sustainLevel = sustainLevelRamper.getAndStep();
            adsr->sus = (float)sustainLevel;
            releaseDuration = releaseDurationRamper.getAndStep();
            adsr->rel = (float)releaseDuration;

            sp_adsr_compute(sp, adsr, &internalGate, &amp);
            
            for (int channel = 0; channel < channels; ++channel) {
                float *in  = (float *)inBufferListPtr->mBuffers[channel].mData  + frameOffset;
                float *out = (float *)outBufferListPtr->mBuffers[channel].mData + frameOffset;
                *out = *in * amp;
            }
        }
    }

    // MARK: Member Variables

private:
    float internalGate = 0;
    float amp = 0;

    sp_adsr *adsr;

    float attackDuration = 0.1;
    float decayDuration = 0.1;
    float sustainLevel = 1.0;
    float releaseDuration = 0.1;

public:
    bool started = false;
    bool resetted = false;
    ParameterRamper attackDurationRamper = 0.1;
    ParameterRamper decayDurationRamper = 0.1;
    ParameterRamper sustainLevelRamper = 1.0;
    ParameterRamper releaseDurationRamper = 0.1;
};

