//
//  AKSawtoothOscillatorDSPKernel.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKSawtoothOscillatorDSPKernel_hpp
#define AKSawtoothOscillatorDSPKernel_hpp

#import "AKDSPKernel.hpp"
#import "AKParameterRamper.hpp"

extern "C" {
#include "soundpipe.h"
}

enum {
    frequencyAddress = 0,
    amplitudeAddress = 1,
    detuningAddress = 2
};

class AKSawtoothOscillatorDSPKernel : public AKDSPKernel {
public:
    // MARK: Member Functions

    AKSawtoothOscillatorDSPKernel() {}

    void init(int channelCount, double inSampleRate) {
        channels = channelCount;

        sampleRate = float(inSampleRate);

        sp_create(&sp);
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
    }

    void setFrequency(float freq) {
        frequency = freq;
        frequencyRamper.set(clamp(freq, (float)0.0, (float)20000.0));
    }

    void setAmplitude(float amp) {
        amplitude = amp;
        amplitudeRamper.set(clamp(amp, (float)0.0, (float)1.0));
    }

    void setDetuning(float detune) {
        detuning = detune;
        detuningRamper.set(clamp(detune, (float)-1000, (float)1000));
    }


    void setParameter(AUParameterAddress address, AUValue value) {
        switch (address) {
            case frequencyAddress:
                frequencyRamper.set(clamp(value, (float)0.0, (float)20000.0));
                break;

            case amplitudeAddress:
                amplitudeRamper.set(clamp(value, (float)0.0, (float)1.0));
                break;

            case detuningAddress:
                detuningRamper.set(clamp(value, (float)-1000, (float)1000));
                break;

        }
    }

    AUValue getParameter(AUParameterAddress address) {
        switch (address) {
            case frequencyAddress:
                return frequencyRamper.goal();

            case amplitudeAddress:
                return amplitudeRamper.goal();

            case detuningAddress:
                return detuningRamper.goal();

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

            case detuningAddress:
                detuningRamper.startRamp(clamp(value, (float)-1000, (float)1000), duration);
                break;

        }
    }

    void setBuffer(AudioBufferList *outBufferList) {
        outBufferListPtr = outBufferList;
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {
        // For each sample.
        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            int frameOffset = int(frameIndex + bufferOffset);

            frequency = double(frequencyRamper.getStep());
            amplitude = double(amplitudeRamper.getStep());
            detuning = double(detuningRamper.getStep());

            *blsaw->freq = frequency + detuning;
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

    int channels = 2;
    float sampleRate = 44100.0;

    AudioBufferList *outBufferListPtr = nullptr;

    sp_data *sp;
    sp_blsaw *blsaw;


    float frequency = 440;
    float amplitude = 0.5;
    float detuning = 0;

public:
    bool started = false;
    AKParameterRamper frequencyRamper = 440;
    AKParameterRamper amplitudeRamper = 0.5;
    AKParameterRamper detuningRamper = 0;
};

#endif /* AKSawtoothOscillatorDSPKernel_hpp */
