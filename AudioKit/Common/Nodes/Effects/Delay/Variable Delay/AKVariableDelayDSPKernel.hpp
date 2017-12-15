//
//  AKVariableDelayDSPKernel.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

#pragma once

#import "AKSoundpipeKernel.hpp"
#import "ParameterRamper.hpp"

#import <AudioKit/AudioKit-Swift.h>

extern "C" {
#include "plumber.h"
}

enum {
    timeAddress = 0,
    feedbackAddress = 1
};

class AKVariableDelayDSPKernel : public AKSoundpipeKernel, public AKBuffered {
public:
    // MARK: Member Functions

    AKVariableDelayDSPKernel() {}

    void init(int _channels, double _sampleRate) override {
        AKSoundpipeKernel::init(_channels, _sampleRate);

        sp_vdelay_create(&vdelay0);
        sp_vdelay_create(&vdelay1);
        sp_vdelay_init(sp, vdelay0, 10.0);
        sp_vdelay_init(sp, vdelay1, 10.0);
        vdelay0->del = 0.0;
        vdelay0->feedback = 0.0;
        vdelay1->del = 0.0;
        vdelay1->feedback = 0.0;

        timeRamper.init();
        feedbackRamper.init();
    }

    void start() {
        started = true;
    }

    void stop() {
        started = false;
    }

    void clear() {
        sp_vdelay_reset(sp, vdelay0);
        sp_vdelay_reset(sp, vdelay1);
    }

    void destroy() {
        sp_vdelay_destroy(&vdelay0);
        sp_vdelay_destroy(&vdelay1);
        AKSoundpipeKernel::destroy();
    }

    void reset() {
        resetted = true;
        sp_vdelay_reset(sp, vdelay0);
        sp_vdelay_reset(sp, vdelay1);
        timeRamper.reset();
        feedbackRamper.reset();
    }

    void setMaxDelayTime(float duration) {
        internalMaxDelay = duration;
    }

    void setTime(float value) {
        time = clamp(value, 0.0f, 10.0f);
        timeRamper.setImmediate(time);
    }

    void setFeedback(float value) {
        feedback = clamp(value, 0.0f, 1.0f);
        feedbackRamper.setImmediate(feedback);
    }


    void setParameter(AUParameterAddress address, AUValue value) {
        switch (address) {
            case timeAddress:
                timeRamper.setUIValue(clamp(value, 0.0f, 10.0f));
                break;

            case feedbackAddress:
                feedbackRamper.setUIValue(clamp(value, 0.0f, 1.0f));
                break;

        }
    }

    AUValue getParameter(AUParameterAddress address) {
        switch (address) {
            case timeAddress:
                return timeRamper.getUIValue();

            case feedbackAddress:
                return feedbackRamper.getUIValue();

            default: return 0.0f;
        }
    }

    void startRamp(AUParameterAddress address, AUValue value, AUAudioFrameCount duration) override {
        switch (address) {
            case timeAddress:
                timeRamper.startRamp(clamp(value, 0.0f, 10.0f), duration);
                break;

            case feedbackAddress:
                feedbackRamper.startRamp(clamp(value, 0.0f, 1.0f), duration);
                break;

        }
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {

        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {

            int frameOffset = int(frameIndex + bufferOffset);

            time = timeRamper.getAndStep();
            vdelay0->del = (float)time;
            vdelay1->del = (float)time;
            feedback = feedbackRamper.getAndStep();
            vdelay0->feedback = (float)feedback;
            vdelay1->feedback = (float)feedback;

            for (int channel = 0; channel < channels; ++channel) {
                float *in  = (float *)inBufferListPtr->mBuffers[channel].mData  + frameOffset;
                float *out = (float *)outBufferListPtr->mBuffers[channel].mData + frameOffset;

                if (started) {
                    if (channel == 0) {
                        sp_vdelay_compute(sp, vdelay0, in, out);
                    } else {
                        sp_vdelay_compute(sp, vdelay1, in, out);
                    }
                } else {
                    *out = *in;
                }
            }
        }
    }

    // MARK: Member Variables

private:

    sp_vdelay *vdelay0;
    sp_vdelay *vdelay1;

    float internalMaxDelay = 10.0;

    float time = 0;
    float feedback = 0;

public:
    bool started = true;
    bool resetted = false;
    ParameterRamper timeRamper = 0;
    ParameterRamper feedbackRamper = 0;
};

