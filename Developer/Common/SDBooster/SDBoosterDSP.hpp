//
//  SDBoosterDSP.hpp
//  ExtendingAudioKit
//
//  Created by Shane Dunne on 1/23/2018
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once

#import <Foundation/Foundation.h>

typedef NS_ENUM(int64_t, SDBoosterParameter) {
    leftGain, rightGain, rampTime
};

#import "AKLinearParameterRamp.hpp"

#ifndef __cplusplus

void* createSDBoosterDSP(int nChannels, double sampleRate);

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

struct SDBoosterDSP : AKDSPBase {

private:
    AKLinearParameterRamp leftGainRamp;
    AKLinearParameterRamp rightGainRamp;

public:

    SDBoosterDSP() {
        leftGainRamp.setTarget(1.0, true);
        leftGainRamp.setDurationInSamples(10000);
        rightGainRamp.setTarget(1.0, true);
        rightGainRamp.setDurationInSamples(10000);
    }

    /** Uses the ParameterAddress as a key */
    void setParameter(uint64_t address, float value, bool immediate) override {
        switch (address) {
            case leftGain:
                leftGainRamp.setTarget(value, immediate);
                break;
            case rightGain:
                rightGainRamp.setTarget(value, immediate);
                break;
            case rampTime:
                leftGainRamp.setRampTime(value, _sampleRate);
                rightGainRamp.setRampTime(value, _sampleRate);
                break;
        }
    }

    /** Uses the ParameterAddress as a key */
    float getParameter(uint64_t address) override {
        switch (address) {
            case leftGain:
                return leftGainRamp.getTarget();
            case rightGain:
                return rightGainRamp.getTarget();
            case rampTime:
                return leftGainRamp.getRampTime(_sampleRate);
        }
        return 0;
    }

    // Largely lifted from the example code, though this is simpler since the Apple code
    // implements a time varying filter

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {

        // For each sample.
        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            int frameOffset = int(frameIndex + bufferOffset);
            // do gain ramping every 8 samples
            if ((frameOffset & 0x7) == 0) {
                leftGainRamp.advanceTo(_now + frameOffset);
                rightGainRamp.advanceTo(_now + frameOffset);
            }
            // do actual signal processing
            // After all this scaffolding, the only thing we are doing is scaling the input
            for (int channel = 0; channel < _nChannels; ++channel) {
                float* in  = (float*)_inBufferListPtr->mBuffers[channel].mData  + frameOffset;
                float* out = (float*)_outBufferListPtr->mBuffers[channel].mData + frameOffset;
                if (channel == 0) {
                    *out = *in * leftGainRamp.getValue();
                } else {
                    *out = *in * rightGainRamp.getValue();
                }
            }
        }
    }

};

#endif
