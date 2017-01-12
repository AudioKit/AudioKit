//
//  AKStereoFieldLimiterDSPKernel.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#pragma once

#import "DSPKernel.hpp"
#import "ParameterRamper.hpp"

#import <AudioKit/AudioKit-Swift.h>

enum {
    amountAddress = 0
};

class AKStereoFieldLimiterDSPKernel : public AKDSPKernel, public AKBuffered {
public:
    // MARK: Member Functions

    AKStereoFieldLimiterDSPKernel() {}

    void init(int channelCount, double inSampleRate) {
        channels = channelCount;

        sampleRate = float(inSampleRate);

        amountRamper.init();
    }

    void start() {
        started = true;
    }

    void stop() {
        started = false;
    }

    void destroy() {
    }
    
    void reset() {
        resetted = true;
        amountRamper.reset();
    }

    void setamount(float value) {
        amount = clamp(value, -100000.0f, 100000.0f);
        amountRamper.setImmediate(amount);
    }


    void setParameter(AUParameterAddress address, AUValue value) {
        switch (address) {
            case amountAddress:
                amountRamper.setUIValue(clamp(value, -100000.0f, 100000.0f));
                break;

        }
    }

    AUValue getParameter(AUParameterAddress address) {
        switch (address) {
            case amountAddress:
                return amountRamper.getUIValue();

            default: return 0.0f;
        }
    }

    void startRamp(AUParameterAddress address, AUValue value, AUAudioFrameCount duration) override {
        switch (address) {
            case amountAddress:
                amountRamper.startRamp(clamp(value, -100000.0f, 100000.0f), duration);
                break;

        }
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {

        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            
            int frameOffset = int(frameIndex + bufferOffset);
            
            amount = amountRamper.getAndStep();
            
            if (!started) {
                outBufferListPtr->mBuffers[0] = inBufferListPtr->mBuffers[0];
                outBufferListPtr->mBuffers[1] = inBufferListPtr->mBuffers[1];
                return;
            }
            
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
            *tmpout[0] = *tmpin[0] * (1.0f - amount) + *tmpin[1];
            *tmpout[1] = *tmpin[1] * (1.0f - amount) + *tmpin[0];
        }
    }

    // MARK: Member Variables

private:

    float amount = 1.0;

public:
    bool started = true;
    bool resetted = false;
    ParameterRamper amountRamper = 0;
};

