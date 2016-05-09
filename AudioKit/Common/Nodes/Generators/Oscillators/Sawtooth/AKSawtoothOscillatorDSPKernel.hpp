//
//  AKSawtoothOscillatorDSPKernel.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKSawtoothOscillatorDSPKernel_hpp
#define AKSawtoothOscillatorDSPKernel_hpp

#import "DSPKernel.hpp"
#import "ParameterRamper.hpp"

#import <AudioKit/AudioKit-Swift.h>

extern "C" {
#include "soundpipe.h"
}

enum {
    frequencyAddress = 0,
    amplitudeAddress = 1,
    detuningOffsetAddress = 2,
    detuningMultiplierAddress = 3
};

class AKSawtoothOscillatorDSPKernel : public DSPKernel {
public:
    // MARK: Member Functions

    AKSawtoothOscillatorDSPKernel() {}

    void init(int channelCount, double inSampleRate) {
        channels = channelCount;

        sampleRate = float(inSampleRate);

        sp_create(&sp);
        sp->sr = sampleRate;
        sp->nchan = channels;
        sp_blsaw_create(&blsaw);
        sp_blsaw_init(sp, blsaw);
        *blsaw->freq = 440;
        *blsaw->amp = 0.5;
    }


    void start() {
        started = true;
    }

    void stop() {
        started = false;
    }

    void destroy() {
        sp_blsaw_destroy(&blsaw);
        sp_destroy(&sp);
    }

    void reset() {
        resetted = true;
    }

    void setFrequency(float freq) {
        frequency = freq;
        frequencyRamper.setImmediate(frequency);
    }
    
    void setAmplitude(float amp) {
        amplitude = amp;
        amplitudeRamper.setImmediate(amplitude);
    }
    
    void setDetuningOffset(float detuneOffset) {
        detuningOffset = detuneOffset;
        detuningOffsetRamper.setImmediate(detuneOffset);
    }
    
    void setDetuningMultiplier(float detuneScale) {
        detuningMultiplier = detuneScale;
        detuningMultiplierRamper.setImmediate(detuneScale);
    }

    void setParameter(AUParameterAddress address, AUValue value) {
        switch (address) {
            case frequencyAddress:
                frequencyRamper.setUIValue(clamp(value, (float)0.0, (float)20000.0));
                break;

            case amplitudeAddress:
                amplitudeRamper.setUIValue(clamp(value, (float)0.0, (float)1.0));
                break;

            case detuningOffsetAddress:
                detuningOffsetRamper.setUIValue(clamp(value, (float)-1000, (float)1000));
                break;

            case detuningMultiplierAddress:
                detuningMultiplierRamper.setUIValue(clamp(value, (float)0.9, (float)1.11));
                break;

        }
    }

    AUValue getParameter(AUParameterAddress address) {
        switch (address) {
            case frequencyAddress:
                return frequencyRamper.getUIValue();

            case amplitudeAddress:
                return amplitudeRamper.getUIValue();

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
                frequencyRamper.startRamp(clamp(value, (float)0.0, (float)20000.0), duration);
                break;

            case amplitudeAddress:
                amplitudeRamper.startRamp(clamp(value, (float)0.0, (float)1.0), duration);
                break;

            case detuningOffsetAddress:
                detuningOffsetRamper.startRamp(clamp(value, (float)-1000, (float)1000), duration);
                break;

            case detuningMultiplierAddress:
                detuningMultiplierRamper.startRamp(clamp(value, (float)0.9, (float)1.11), duration);
                break;

        }
    }

    void setBuffer(AudioBufferList *outBufferList) {
        outBufferListPtr = outBufferList;
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {

        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            int frameOffset = int(frameIndex + bufferOffset);

            frequency = double(frequencyRamper.getAndStep());
            amplitude = double(amplitudeRamper.getAndStep());
            detuningOffset = double(detuningOffsetRamper.getAndStep());
            detuningMultiplier = double(detuningMultiplierRamper.getAndStep());

            *blsaw->freq = frequency * detuningMultiplier + detuningOffset;
            *blsaw->amp = amplitude;

            float temp = 0;
            for (int channel = 0; channel < channels; ++channel) {
                float *out = (float *)outBufferListPtr->mBuffers[channel].mData + frameOffset;
                if (started) {
                    if (channel == 0) {
                        sp_blsaw_compute(sp, blsaw, nil, &temp);
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

    int channels = AKSettings.numberOfChannels;
    float sampleRate = AKSettings.sampleRate;

    AudioBufferList *outBufferListPtr = nullptr;

    sp_data *sp;
    sp_blsaw *blsaw;


    float frequency = 440;
    float amplitude = 0.5;
    float detuningOffset = 0;
    float detuningMultiplier = 1;

public:
    bool started = false;
    bool resetted = false;
    ParameterRamper frequencyRamper = 440;
    ParameterRamper amplitudeRamper = 0.5;
    ParameterRamper detuningOffsetRamper = 0;
    ParameterRamper detuningMultiplierRamper = 1;
};

#endif /* AKSawtoothOscillatorDSPKernel_hpp */
