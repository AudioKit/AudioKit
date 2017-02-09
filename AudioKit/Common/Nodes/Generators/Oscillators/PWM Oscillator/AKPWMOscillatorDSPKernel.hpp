//
//  AKPWMOscillatorDSPKernel.hpp
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
}

enum {
    frequencyAddress = 0,
    amplitudeAddress = 1,
    pulseWidthAddress = 2,
    detuningOffsetAddress = 3,
    detuningMultiplierAddress = 4
};

class AKPWMOscillatorDSPKernel : public AKSoundpipeKernel, public AKOutputBuffered {
public:
    // MARK: Member Functions

    AKPWMOscillatorDSPKernel() {}

    void init(int _channels, double _sampleRate) override {
        AKSoundpipeKernel::init(_channels, _sampleRate);

        sp_blsquare_create(&blsquare);
        sp_blsquare_init(sp, blsquare);
        *blsquare->freq = 440;
        *blsquare->amp = 1.0;
        *blsquare->width = 0.5;

        frequencyRamper.init();
        amplitudeRamper.init();
        pulseWidthRamper.init();
        detuningOffsetRamper.init();
        detuningMultiplierRamper.init();
    }

    void start() {
        started = true;
    }

    void stop() {
        started = false;
    }

    void destroy() {
        sp_blsquare_destroy(&blsquare);
        AKSoundpipeKernel::destroy();
    }

    void reset() {
        resetted = true;
        frequencyRamper.reset();
        amplitudeRamper.reset();
        pulseWidthRamper.reset();
        detuningOffsetRamper.reset();
        detuningMultiplierRamper.reset();
    }

    void setFrequency(float value) {
        frequency = clamp(value, 0.0f, 20000.0f);
        frequencyRamper.setImmediate(frequency);
    }

    void setAmplitude(float value) {
        amplitude = clamp(value, 0.0f, 10.0f);
        amplitudeRamper.setImmediate(amplitude);
    }

    void setDetuningOffset(float value) {
        detuningOffset = clamp(value, -1000.0f, 1000.0f);
        detuningOffsetRamper.setImmediate(detuningOffset);
    }

    void setDetuningMultiplier(float value) {
        detuningMultiplier = value;
        detuningMultiplierRamper.setImmediate(detuningMultiplier);
    }
    
    void setPulseWidth(float value) {
        pulseWidth = clamp(value, 0.0f, 1.0f);
        pulseWidthRamper.setImmediate(pulseWidth);
    }


    void setParameter(AUParameterAddress address, AUValue value) {
        switch (address) {
            case frequencyAddress:
                frequencyRamper.setUIValue(clamp(value, 0.0f, 20000.0f));
                break;

            case amplitudeAddress:
                amplitudeRamper.setUIValue(clamp(value, 0.0f, 10.0f));
                break;

            case pulseWidthAddress:
                pulseWidthRamper.setUIValue(clamp(value, 0.0f, 1.0f));
                break;

            case detuningOffsetAddress:
                detuningOffsetRamper.setUIValue(clamp(value, -1000.0f, 1000.0f));
                break;

            case detuningMultiplierAddress:
                detuningMultiplierRamper.setUIValue(value);
                break;

        }
    }

    AUValue getParameter(AUParameterAddress address) {
        switch (address) {
            case frequencyAddress:
                return frequencyRamper.getUIValue();

            case amplitudeAddress:
                return amplitudeRamper.getUIValue();

            case pulseWidthAddress:
                return pulseWidthRamper.getUIValue();

            case detuningOffsetAddress:
                return detuningOffsetRamper.getUIValue();

            case detuningMultiplierAddress:
                return detuningMultiplierRamper.getUIValue();

            default: return 0.0f;
        }
    }

    void startRamp(AUParameterAddress address, AUValue value, AUAudioFrameCount duration) override {
        switch (address) {
            case frequencyAddress:
                frequencyRamper.startRamp(clamp(value, 0.0f, 20000.0f), duration);
                break;

            case amplitudeAddress:
                amplitudeRamper.startRamp(clamp(value, 0.0f, 10.0f), duration);
                break;

            case pulseWidthAddress:
                pulseWidthRamper.startRamp(clamp(value, 0.0f, 1.0f), duration);
                break;

            case detuningOffsetAddress:
                detuningOffsetRamper.startRamp(clamp(value, -1000.0f, 1000.0f), duration);
                break;

            case detuningMultiplierAddress:
                detuningMultiplierRamper.startRamp(value, duration);
                break;

        }
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {

        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {

            int frameOffset = int(frameIndex + bufferOffset);

            frequency = double(frequencyRamper.getAndStep());
            amplitude = double(amplitudeRamper.getAndStep());
            pulseWidth = double(pulseWidthRamper.getAndStep());
            detuningOffset = double(detuningOffsetRamper.getAndStep());
            detuningMultiplier = double(detuningMultiplierRamper.getAndStep());

            *blsquare->freq = frequency * detuningMultiplier + detuningOffset;
            *blsquare->amp = amplitude;
            *blsquare->width = pulseWidth;

            float temp = 0;
            for (int channel = 0; channel < channels; ++channel) {
                float *out = (float *)outBufferListPtr->mBuffers[channel].mData + frameOffset;
                if (started) {
                    if (channel == 0) {
                        sp_blsquare_compute(sp, blsquare, nil, &temp);
                    }
                    *out = temp;
                } else {
                    *out = 0.0;
                }
            }
        }
    }

    // MARK: Member Variables

private:

    sp_blsquare *blsquare;

    float frequency = 440;
    float amplitude = 1.0;
    float pulseWidth = 0.5;
    float detuningOffset = 0;
    float detuningMultiplier = 1;

public:
    bool started = false;
    bool resetted = false;
    ParameterRamper frequencyRamper = 440;
    ParameterRamper amplitudeRamper = 1.0;
    ParameterRamper pulseWidthRamper = 0.5;
    ParameterRamper detuningOffsetRamper = 0;
    ParameterRamper detuningMultiplierRamper = 1;
};

