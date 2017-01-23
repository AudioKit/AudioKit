//
//  AKBoosterDSPKernel.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2017 Aurelius Prochazka. All rights reserved.
//

#pragma once

#import "DSPKernel.hpp"
#import "ParameterRamper.hpp"

#import <AudioKit/AudioKit-Swift.h>

enum {
    gainAddress = 0
};

class AKBoosterDSPKernel : public AKDSPKernel, public AKBuffered {
public:
    // MARK: Member Functions

    AKBoosterDSPKernel() {}

    void init(int _channels, double _sampleRate) override {
        AKDSPKernel::init(_channels, _sampleRate);
        gainRamper.init();
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
        gainRamper.reset();
    }

    void setGain(float value) {
        gain = clamp(value, -100000.0f, 100000.0f);
        gainRamper.setImmediate(gain);
    }


    void setParameter(AUParameterAddress address, AUValue value) {
        switch (address) {
            case gainAddress:
                gainRamper.setUIValue(clamp(value, -100000.0f, 100000.0f));
                break;

        }
    }

    AUValue getParameter(AUParameterAddress address) {
        switch (address) {
            case gainAddress:
                return gainRamper.getUIValue();

            default: return 0.0f;
        }
    }

    void startRamp(AUParameterAddress address, AUValue value, AUAudioFrameCount duration) override {
        switch (address) {
            case gainAddress:
                gainRamper.startRamp(clamp(value, -100000.0f, 100000.0f), duration);
                break;

        }
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {

        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {

            int frameOffset = int(frameIndex + bufferOffset);

            gain = gainRamper.getAndStep();

            if (!started) {
                outBufferListPtr->mBuffers[0] = inBufferListPtr->mBuffers[0];
                outBufferListPtr->mBuffers[1] = inBufferListPtr->mBuffers[1];
                return;
            }
            
            for (int channel = 0; channel < channels; ++channel) {
                float *in  = (float *)inBufferListPtr->mBuffers[channel].mData  + frameOffset;
                float *out = (float *)outBufferListPtr->mBuffers[channel].mData + frameOffset;
                *out = *in * gain;
            }
        }
    }

    // MARK: Member Variables

private:

    float gain = 1.0;

public:
    bool started = true;
    bool resetted = false;
    ParameterRamper gainRamper = 0;
};

