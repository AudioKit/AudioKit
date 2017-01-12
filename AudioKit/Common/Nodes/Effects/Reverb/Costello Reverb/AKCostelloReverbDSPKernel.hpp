//
//  AKCostelloReverbDSPKernel.hpp
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
    feedbackAddress = 0,
    cutoffFrequencyAddress = 1
};

class AKCostelloReverbDSPKernel : public AKDSPKernel, public AKBuffered {
public:
    // MARK: Member Functions

    AKCostelloReverbDSPKernel() {}

    void init(int channelCount, double inSampleRate) {
        AKDSPKernel::init(channelCount, inSampleRate);
        sp_create(&sp);
        sp->sr = sampleRate;
        sp->nchan = channels;
        sp_revsc_create(&revsc);
        sp_revsc_init(sp, revsc);
        revsc->feedback = 0.6;
        revsc->lpfreq = 4000;

        feedbackRamper.init();
        cutoffFrequencyRamper.init();
    }

    void start() {
        started = true;
    }

    void stop() {
        started = false;
    }

    void destroy() {
        sp_revsc_destroy(&revsc);
        sp_destroy(&sp);
    }

    void reset() {
        resetted = true;
        feedbackRamper.reset();
        cutoffFrequencyRamper.reset();
    }

    void setFeedback(float value) {
        feedback = clamp(value, 0.0f, 1.0f);
        feedbackRamper.setImmediate(feedback);
    }

    void setCutoffFrequency(float value) {
        cutoffFrequency = clamp(value, 12.0f, 20000.0f);
        cutoffFrequencyRamper.setImmediate(cutoffFrequency);
    }


    void setParameter(AUParameterAddress address, AUValue value) {
        switch (address) {
            case feedbackAddress:
                feedbackRamper.setUIValue(clamp(value, 0.0f, 1.0f));
                break;

            case cutoffFrequencyAddress:
                cutoffFrequencyRamper.setUIValue(clamp(value, 12.0f, 20000.0f));
                break;

        }
    }

    AUValue getParameter(AUParameterAddress address) {
        switch (address) {
            case feedbackAddress:
                return feedbackRamper.getUIValue();

            case cutoffFrequencyAddress:
                return cutoffFrequencyRamper.getUIValue();

            default: return 0.0f;
        }
    }

    void startRamp(AUParameterAddress address, AUValue value, AUAudioFrameCount duration) override {
        switch (address) {
            case feedbackAddress:
                feedbackRamper.startRamp(clamp(value, 0.0f, 1.0f), duration);
                break;

            case cutoffFrequencyAddress:
                cutoffFrequencyRamper.startRamp(clamp(value, 12.0f, 20000.0f), duration);
                break;

        }
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {

        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {

            int frameOffset = int(frameIndex + bufferOffset);

            feedback = feedbackRamper.getAndStep();
            revsc->feedback = (float)feedback;
            cutoffFrequency = cutoffFrequencyRamper.getAndStep();
            revsc->lpfreq = (float)cutoffFrequency;

            float *tmpin[2];
            float *tmpout[2];
            for (int channel = 0; channel < channels; ++channel) {
                float *in  = (float *)inBufferListPtr->mBuffers[channel].mData  + frameOffset;
                float *out = (float *)outBufferListPtr->mBuffers[channel].mData + frameOffset;

                if (channel < 2) {
                    tmpin[channel] = in;
                    tmpout[channel] = out;
                }
            }
            if (started) {
                sp_revsc_compute(sp, revsc, tmpin[0], tmpin[1], tmpout[0], tmpout[1]);
            } else {
                tmpout[0] = tmpin[0];
                tmpout[1] = tmpin[1];
            }
        }
    }

    // MARK: Member Variables

private:

    sp_data *sp;
    sp_revsc *revsc;

    float feedback = 0.6;
    float cutoffFrequency = 4000;

public:
    bool started = true;
    bool resetted = false;
    ParameterRamper feedbackRamper = 0.6;
    ParameterRamper cutoffFrequencyRamper = 4000;
};

