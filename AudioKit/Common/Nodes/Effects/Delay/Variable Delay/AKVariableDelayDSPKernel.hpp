//
//  AKVariableDelayDSPKernel.hpp
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
#include "plumber.h"
}

enum {
    timeAddress = 0,
    feedbackAddress = 1
};

class AKVariableDelayDSPKernel : public AKDSPKernel, public AKBuffered {
public:
    // MARK: Member Functions

    AKVariableDelayDSPKernel() {}

    void init(int channelCount, double inSampleRate) {
        AKDSPKernel::init(channelCount, inSampleRate);
        sp_create(&sp);
        sp->sr = sampleRate;
        sp->nchan = channels;
        plumber_register(&pd);
        plumber_init(&pd);
        pd.sp = sp;
        NSString *sporth = [NSString stringWithFormat:@"0 p 1 p 2 p %f vdelay dup", internalMaxDelay];
        char *sporthCode = (char *)[sporth UTF8String];
        plumber_parse_string(&pd, sporthCode);
        plumber_compute(&pd, PLUMBER_INIT);

        timeRamper.init();
        feedbackRamper.init();
    }

    void start() {
        started = true;
    }

    void stop() {
        started = false;
    }

    void destroy() {
        plumber_clean(&pd);
        sp_destroy(&sp);
    }

    void reset() {
        resetted = true;
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
            feedback = feedbackRamper.getAndStep();

            if (!started) {
                outBufferListPtr->mBuffers[0] = inBufferListPtr->mBuffers[0];
                outBufferListPtr->mBuffers[1] = inBufferListPtr->mBuffers[1];
                return;
            }
            for (int channel = 0; channel < channels; ++channel) {
                float *in  = (float *)inBufferListPtr->mBuffers[channel].mData  + frameOffset;
                if (channel < 2) {
                    pd.p[channel] = *in;
                }
            }
            pd.p[1] = (float)feedback;
            pd.p[2] = (float)time;
            plumber_compute(&pd, PLUMBER_COMPUTE);
            
            for (int channel = 0; channel < channels; ++channel) {
                float *out = (float *)outBufferListPtr->mBuffers[channel].mData + frameOffset;
                *out = sporth_stack_pop_float(&pd.sporth.stack);
            }
        }
    }

    // MARK: Member Variables

private:
    sp_data *sp;
    plumber_data pd;
    
    float internalMaxDelay = 5.0;

    float time = 1;
    float feedback = 0;

public:
    bool started = true;
    bool resetted = false;
    ParameterRamper timeRamper = 1;
    ParameterRamper feedbackRamper = 0;
};

