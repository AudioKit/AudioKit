//
//  AKStereoFieldLimiterDSP.hpp
//  AudioKit
//
//  Created by Andrew Voelkel on 9/23/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

#pragma once

#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(AUParameterAddress, AKStereoFieldLimiterParameter) {
    AKStereoFieldLimiterParameterAmount,
    AKStereoFieldLimiterParameterRampTime
};

#import "AKLinearParameterRamp.hpp"  // have to put this here to get it included in umbrella header

#ifndef __cplusplus

void* createStereoFieldLimiterDSP(int nChannels, double sampleRate);

#else

#import <AudioToolbox/AudioToolbox.h>
#import <AudioUnit/AudioUnit.h>
#import <AVFoundation/AVFoundation.h>

/**
 A butt simple DSP kernel. Most of the plumbing is in the base class. All the code at this
 level has to do is supply the core of the rendering code. A less trivial example would probably
 need to coordinate the updating of DSP parameters, which would probably involve thread locks,
 etc.
 */

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
            case AKStereoFieldLimiterParameterRampTime:
                amountRamp.setRampTime(value, _sampleRate);
                break;
        }
    }

    /** Uses the ParameterAddress as a key */
    float getParameter(AUParameterAddress address) override {
        switch (address) {
            case AKStereoFieldLimiterParameterAmount:
                return amountRamp.getTarget();
            case AKStereoFieldLimiterParameterRampTime:
                return amountRamp.getRampTime(_sampleRate);
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
                amountRamp.advanceTo(_now + frameOffset);
            }
            float amount = amountRamp.getValue();

            if (!_playing) {
                _outBufferListPtr->mBuffers[0] = _inBufferListPtr->mBuffers[0];
                _outBufferListPtr->mBuffers[1] = _inBufferListPtr->mBuffers[1];
                return;
            }

            float *tmpin[2];
            float *tmpout[2];
            for (int channel = 0; channel < _nChannels; ++channel) {
                float *in  = (float *)_inBufferListPtr->mBuffers[channel].mData  + frameOffset;
                float *out = (float *)_outBufferListPtr->mBuffers[channel].mData + frameOffset;
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




