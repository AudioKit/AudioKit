//
//  AKFluteDSPKernel.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#pragma once
#import "DSPKernel.hpp"
#import "ParameterRamper.hpp"

#import <AudioKit/AudioKit-Swift.h>

#include "Flute.h"

enum {
    frequencyAddress = 0,
    amplitudeAddress = 1
};

class AKFluteDSPKernel : public DSPKernel {
public:
    // MARK: Member Functions

    AKFluteDSPKernel() {}

    void init(int channelCount, double inSampleRate) {
        channels = channelCount;

        sampleRate = float(inSampleRate);

        // iOS Hack
        NSBundle *frameworkBundle = [NSBundle bundleForClass:[AKOscillator class]];
        NSString *resourcePath = [frameworkBundle resourcePath];
        stk::Stk::setRawwavePath([resourcePath cStringUsingEncoding:NSUTF8StringEncoding]);
        
        stk::Stk::setSampleRate(sampleRate);
        flute = new stk::Flute(100);
    }

    void start() {
        started = true;
    }

    void stop() {
        started = false;
    }

    void destroy() {
        delete flute;
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

    void setBuffer(AudioBufferList *outBufferList) {
        outBufferListPtr = outBufferList;
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
                        flute->noteOn(frequency, amplitude);
                    }
                    *out = flute->tick();
                } else {
                    *out = 0.0;
                }
            }
        }
        if (internalTrigger == 1) {
            internalTrigger = 0;
        }
    }

    // MARK: Member Variables

private:

    int channels = AKSettings.numberOfChannels;
    float sampleRate = AKSettings.sampleRate;
    float internalTrigger = 0;

    AudioBufferList *outBufferListPtr = nullptr;

    stk::Flute *flute;
    
    float frequency = 110;
    float amplitude = 0.5;

public:
    bool started = false;
    bool resetted = false;
    ParameterRamper frequencyRamper = 110;
    ParameterRamper amplitudeRamper = 0.5;
};


