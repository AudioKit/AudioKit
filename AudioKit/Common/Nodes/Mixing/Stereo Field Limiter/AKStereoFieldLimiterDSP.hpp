//
//  AKStereoFieldLimiterDSP.hpp
//  AudioKit
//
//  Created by Andrew Voelkel, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once

#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(AUParameterAddress, AKStereoFieldLimiterParameter) {
    AKStereoFieldLimiterParameterAmount,
    AKStereoFieldLimiterParameterRampDuration
};

#import "AKLinearParameterRamp.hpp"  // have to put this here to get it included in umbrella header

#ifndef __cplusplus

AKDSPRef createStereoFieldLimiterDSP(int channelCount, double sampleRate);

#else

#import <AudioToolbox/AudioToolbox.h>
#import <AudioUnit/AudioUnit.h>
#import <AVFoundation/AVFoundation.h>

struct AKStereoFieldLimiterDSP : AKDSPBase {

private:
    AKLinearParameterRamp amountRamp;

public:

    AKStereoFieldLimiterDSP() {
        amountRamp.setTarget(1.0, true);
        amountRamp.setDurationInSamples(10000);
    }

    /** Uses the ParameterAddress as a key */
    void setParameter(AUParameterAddress address, float value, bool immediate) override {
        switch (address) {
            case AKStereoFieldLimiterParameterAmount:
                amountRamp.setTarget(value, immediate);
                break;
            case AKStereoFieldLimiterParameterRampDuration:
                amountRamp.setRampDuration(value, sampleRate);
                break;
        }
    }

    /** Uses the ParameterAddress as a key */
    float getParameter(AUParameterAddress address) override {
        switch (address) {
            case AKStereoFieldLimiterParameterAmount:
                return amountRamp.getTarget();
            case AKStereoFieldLimiterParameterRampDuration:
                return amountRamp.getRampDuration(sampleRate);
        }
        return 0;
    }

    // Largely lifted from the example code, though this is simpler since the Apple code
    // implements a time varying filter

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {

        // For each sample.
        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            int frameOffset = int(frameIndex + bufferOffset);
            // do ramping every 8 samples
            if ((frameOffset & 0x7) == 0) {
                amountRamp.advanceTo(now + frameOffset);
            }
            float amount = amountRamp.getValue();

            if (!isStarted) {
                outBufferListPtr->mBuffers[0] = inBufferListPtr->mBuffers[0];
                outBufferListPtr->mBuffers[1] = inBufferListPtr->mBuffers[1];
                return;
            }

            float *tmpin[2];
            float *tmpout[2];
            for (int channel = 0; channel < channelCount; ++channel) {
                float *in  = (float *)inBufferListPtr->mBuffers[channel].mData  + frameOffset;
                float *out = (float *)outBufferListPtr->mBuffers[channel].mData + frameOffset;
                if (channel < 2) {
                    tmpin[channel] = in;
                    tmpout[channel] = out;
                }
            }
            *tmpout[0] = *tmpin[0] * (1.0f - amount / 2.0) + *tmpin[1] * amount / 2.0;
            *tmpout[1] = *tmpin[1] * (1.0f - amount / 2.0) + *tmpin[0] * amount / 2.0;
        }
    }
};

#endif




