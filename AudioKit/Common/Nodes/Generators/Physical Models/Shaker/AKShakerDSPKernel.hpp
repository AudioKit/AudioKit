//
//  AKShakerDSPKernel.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

#pragma once

#import "DSPKernel.hpp"
#import "ParameterRamper.hpp"

#import <AudioKit/AudioKit-Swift.h>

#include "Shakers.h"

enum {
    amplitudeAddress = 0
};

class AKShakerDSPKernel : public AKDSPKernel, public AKOutputBuffered {
public:
    // MARK: Member Functions

    AKShakerDSPKernel() {}

    void init(int _channels, double _sampleRate) override {
        AKDSPKernel::init(_channels, _sampleRate);
        // iOS Hack
        NSBundle *frameworkBundle = [NSBundle bundleForClass:[AKOscillator class]];
        NSString *resourcePath = [frameworkBundle resourcePath];
        stk::Stk::setRawwavePath([resourcePath cStringUsingEncoding:NSUTF8StringEncoding]);
        
        stk::Stk::setSampleRate(sampleRate);
        shaker = new stk::Shakers(0);
    }

    void start() {
        started = true;
    }

    void stop() {
        started = false;
    }

    void destroy() {
        delete shaker;
    }

    void reset() {
        resetted = true;
    }
    
    void setType(UInt8 typ) {
        type = typ;
    }

    void setAmplitude(float amp) {
        amplitude = amp;
        amplitudeRamper.setImmediate(amp);
    }

    void trigger() {
        internalTrigger = 1;
    }

    void setParameter(AUParameterAddress address, AUValue value) {
        switch (address) {
                
            case amplitudeAddress:
                amplitudeRamper.setUIValue(clamp(value, (float)0, (float)1));
                break;

        }
    }

    AUValue getParameter(AUParameterAddress address) {
        switch (address) {
            case amplitudeAddress:
                return amplitudeRamper.getUIValue();

            default: return 0.0f;
        }
    }

    void startRamp(AUParameterAddress address, AUValue value, AUAudioFrameCount duration) override {
        switch (address) {
            case amplitudeAddress:
                amplitudeRamper.startRamp(clamp(value, (float)0, (float)1), duration);
                break;

        }
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {

        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {

            int frameOffset = int(frameIndex + bufferOffset);

            amplitude = amplitudeRamper.getAndStep();

            for (int channel = 0; channel < channels; ++channel) {
                float *out = (float *)outBufferListPtr->mBuffers[channel].mData + frameOffset;
                if (started) {
                    if (internalTrigger == 1) {
                        shaker->noteOn(type, amplitude);
                    }
                } else {
                    *out = 0.0;
                }
                *out = shaker->tick();
            }
        }
        if (internalTrigger == 1) {
            internalTrigger = 0;
        }
    }

    // MARK: Member Variables

private:

    float internalTrigger = 0;

    stk::Shakers *shaker;
    
    UInt8 type = 0;
    float amplitude = 0.5;

public:
    bool started = false;
    bool resetted = false;
    ParameterRamper amplitudeRamper = 0.5;
};

