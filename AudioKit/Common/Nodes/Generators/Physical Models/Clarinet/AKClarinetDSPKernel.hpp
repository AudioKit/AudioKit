//
//  AKClarinetDSPKernel.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#pragma once

#import "DSPKernel.hpp"
#import "ParameterRamper.hpp"

#import <AudioKit/AudioKit-Swift.h>

#include "Clarinet.h"

enum {
    frequencyAddress = 0,
    amplitudeAddress = 1
};

class AKClarinetDSPKernel : public AKDSPKernel, public AKOutputBuffered {
public:
    // MARK: Member Functions

    AKClarinetDSPKernel() {}

    void init(int channelCount, double inSampleRate) {
        channels = channelCount;

        sampleRate = float(inSampleRate);

        // iOS Hack
        NSBundle *frameworkBundle = [NSBundle bundleForClass:[AKOscillator class]];
        NSString *resourcePath = [frameworkBundle resourcePath];
        stk::Stk::setRawwavePath([resourcePath cStringUsingEncoding:NSUTF8StringEncoding]);
        
        stk::Stk::setSampleRate(sampleRate);
        clarinet = new stk::Clarinet(100);
    }

    void start() {
        started = true;
    }

    void stop() {
        started = false;
    }

    void destroy() {
        delete clarinet;
    }

    void reset() {
        resetted = true;
    }

    void setFrequency(float freq) {
        frequency = freq;
        frequencyRamper.setImmediate(freq);
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
            case frequencyAddress:
                frequencyRamper.setUIValue(clamp(value, (float)0, (float)22000));
                break;

            case amplitudeAddress:
                amplitudeRamper.setUIValue(clamp(value, (float)0, (float)1));
                break;

        }
    }

    AUValue getParameter(AUParameterAddress address) {
        switch (address) {
            case frequencyAddress:
                return frequencyRamper.getUIValue();

            case amplitudeAddress:
                return amplitudeRamper.getUIValue();

            default: return 0.0f;
        }
    }

    void startRamp(AUParameterAddress address, AUValue value, AUAudioFrameCount duration) override {
        switch (address) {
            case frequencyAddress:
                frequencyRamper.startRamp(clamp(value, (float)0, (float)22000), duration);
                break;

            case amplitudeAddress:
                amplitudeRamper.startRamp(clamp(value, (float)0, (float)1), duration);
                break;

        }
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {

        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {

            int frameOffset = int(frameIndex + bufferOffset);

            frequency = frequencyRamper.getAndStep();
            amplitude = amplitudeRamper.getAndStep();

            for (int channel = 0; channel < channels; ++channel) {
                float *out = (float *)outBufferListPtr->mBuffers[channel].mData + frameOffset;
                if (started) {
                    if (internalTrigger == 1) {
                        clarinet->noteOn(frequency, amplitude);
                    }
                } else {
                    *out = 0.0;
                }
                *out = clarinet->tick();
            }
        }
        if (internalTrigger == 1) {
            internalTrigger = 0;
        }
    }

    // MARK: Member Variables

private:

    float internalTrigger = 0;

    stk::Clarinet *clarinet;
    
    float frequency = 110;
    float amplitude = 0.5;

public:
    bool started = false;
    bool resetted = false;
    ParameterRamper frequencyRamper = 110;
    ParameterRamper amplitudeRamper = 0.5;
};

