//
//  AKBoosterDSPKernel.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

#pragma once

#import "AKDSPKernel.hpp"
#import "ParameterRamper.hpp"

#import <AudioKit/AudioKit-Swift.h>

enum {
    leftGainAddress = 0,
    rightGainAddress = 1
};

class AKBoosterDSPKernel : public AKDSPKernel, public AKBuffered {
public:
    // MARK: Member Functions

    AKBoosterDSPKernel() {}

    void init(int _channels, double _sampleRate) override {
        AKDSPKernel::init(_channels, _sampleRate);
        leftGainRamper.init();
        rightGainRamper.init();
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
        leftGainRamper.reset();
        rightGainRamper.reset();
    }

    void setLeftGain(float value) {
        leftGain = clamp(value, -100000.0f, 100000.0f);
        leftGainRamper.setImmediate(leftGain);
    }

    void setRightGain(float value) {
        rightGain = clamp(value, -100000.0f, 100000.0f);
        rightGainRamper.setImmediate(rightGain);
    }


    void setParameter(AUParameterAddress address, AUValue value) {
        switch (address) {
            case leftGainAddress:
                leftGainRamper.setUIValue(clamp(value, -100000.0f, 100000.0f));
                break;
            case rightGainAddress:
                rightGainRamper.setUIValue(clamp(value, -100000.0f, 100000.0f));
                break;

        }
    }

    AUValue getParameter(AUParameterAddress address) {
        switch (address) {
            case leftGainAddress:
                return leftGainRamper.getUIValue();
            case rightGainAddress:
                return rightGainRamper.getUIValue();

            default: return 0.0f;
        }
    }

    void startRamp(AUParameterAddress address, AUValue value, AUAudioFrameCount duration) override {
        switch (address) {
            case leftGainAddress:
                leftGainRamper.startRamp(clamp(value, -100000.0f, 100000.0f), duration);
                break;
            case rightGainAddress:
                rightGainRamper.startRamp(clamp(value, -100000.0f, 100000.0f), duration);
                break;

        }
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {

        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {

            int frameOffset = int(frameIndex + bufferOffset);

            leftGain = leftGainRamper.getAndStep();
            rightGain = rightGainRamper.getAndStep();

            if (!started) {
                outBufferListPtr->mBuffers[0] = inBufferListPtr->mBuffers[0];
                outBufferListPtr->mBuffers[1] = inBufferListPtr->mBuffers[1];
                return;
            }
            
            for (int channel = 0; channel < channels; ++channel) {
                float *in  = (float *)inBufferListPtr->mBuffers[channel].mData  + frameOffset;
                float *out = (float *)outBufferListPtr->mBuffers[channel].mData + frameOffset;
                if (channel == 0) {
                    *out = *in * leftGain;
                } else {
                    *out = *in * rightGain;
                }
            }
        }
    }

    // MARK: Member Variables

private:

    float leftGain = 1.0;
    float rightGain = 1.0;

public:
    bool started = true;
    bool resetted = false;
    ParameterRamper leftGainRamper = 1;
    ParameterRamper rightGainRamper = 1;
};

