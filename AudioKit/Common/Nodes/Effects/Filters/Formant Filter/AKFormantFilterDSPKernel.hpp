//
//  AKFormantFilterDSPKernel.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2017 Aurelius Prochazka. All rights reserved.
//

#pragma once

#import "DSPKernel.hpp"
#import "ParameterRamper.hpp"

#import <AudioKit/AudioKit-Swift.h>

extern "C" {
#include "soundpipe.h"
#include "growl.h"
}

enum {
    xAddress = 0,
    yAddress = 1
};

class AKFormantFilterDSPKernel : public AKSoundpipeKernel, public AKBuffered {
public:
    // MARK: Member Functions

    AKFormantFilterDSPKernel() {}

    void init(int _channels, double _sampleRate) override {
        AKSoundpipeKernel::init(_channels, _sampleRate);

        growl_create(&growl);
        growl_init(sp, growl);

        growl->x = 0;
        growl->y = 0;

        xRamper.init();
        yRamper.init();
    }

    void start() {
        started = true;
    }

    void stop() {
        started = false;
    }

    void destroy() {
        growl_destroy(&growl);
        AKSoundpipeKernel::destroy();
    }

    void reset() {
        resetted = true;
        xRamper.reset();
        yRamper.reset();
    }

    void setX(float value) {
        x = clamp(value, 0.0f, 1.0f);
        xRamper.setImmediate(x);
    }

    void setY(float value) {
        y = clamp(value, 0.0f, 1.0f);
        yRamper.setImmediate(y);
    }

    void setParameter(AUParameterAddress address, AUValue value) {
        switch (address) {
            case xAddress:
                xRamper.setUIValue(clamp(value, 0.0f, 1.0f));
                break;

            case yAddress:
                yRamper.setUIValue(clamp(value, 0.0f, 1.0f));
                break;
        }
    }

    AUValue getParameter(AUParameterAddress address) {
        switch (address) {
            case xAddress:
                return xRamper.getUIValue();

            case yAddress:
                return yRamper.getUIValue();

            default: return 0.0f;
        }
    }

    void startRamp(AUParameterAddress address, AUValue value, AUAudioFrameCount duration) override {
        switch (address) {
            case xAddress:
                xRamper.startRamp(clamp(value, 0.0f, 1.0f), duration);
                break;

            case yAddress:
                yRamper.startRamp(clamp(value, 0.0f, 1.0f), duration);
                break;

        }
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {

        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {

            int frameOffset = int(frameIndex + bufferOffset);

            x = xRamper.getAndStep();
            growl->x = (float)x;
            y = yRamper.getAndStep();
            growl->y = (float)y;

            for (int channel = 0; channel < channels; ++channel) {
                float *in  = (float *)inBufferListPtr->mBuffers[channel].mData  + frameOffset;
                float *out = (float *)outBufferListPtr->mBuffers[channel].mData + frameOffset;
                
                if (started) {
                    growl_compute(sp, growl, in, out);
                    *out = *in;
                } else {
                    *out = *in;
                }
            }
        }
    }

    // MARK: Member Variables

private:
    
    growl_d *growl;
    float x = 0;
    float y = 0;

public:
    bool started = true;
    bool resetted = false;
    ParameterRamper xRamper = 0;
    ParameterRamper yRamper = 0;
};

