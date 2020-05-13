// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#pragma once

#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(AUParameterAddress, AKStereoFieldLimiterParameter) {
    AKStereoFieldLimiterParameterAmount,
};

#ifndef __cplusplus

AKDSPRef createStereoFieldLimiterDSP(void);

#else

#import "AKDSPBase.hpp"
#import "AKLinearParameterRamp.hpp"

struct AKStereoFieldLimiterDSP : AKDSPBase {
private:
    AKLinearParameterRamp amountRamp;

public:

    AKStereoFieldLimiterDSP() {
        parameters[AKStereoFieldLimiterParameterAmount] = &amountRamp;
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {
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




