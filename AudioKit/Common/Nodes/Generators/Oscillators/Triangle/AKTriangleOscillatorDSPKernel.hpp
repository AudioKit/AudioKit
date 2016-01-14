//
//  AKTriangleOscillatorDSPKernel.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, last edited January 13, 2016.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKTriangleOscillatorDSPKernel_hpp
#define AKTriangleOscillatorDSPKernel_hpp

#import "AKDSPKernel.hpp"
#import "AKParameterRamper.hpp"

extern "C" {
#include "soundpipe.h"
}

enum {
    frequencyAddress = 0,
    amplitudeAddress = 1
};

class AKTriangleOscillatorDSPKernel : public AKDSPKernel {
public:
    // MARK: Member Functions

    AKTriangleOscillatorDSPKernel() {}

    void init(int channelCount, double inSampleRate) {
        channels = channelCount;

        sampleRate = float(inSampleRate);

        sp_create(&sp);
        sp_bltriangle_create(&bltriangle);
        sp_bltriangle_init(sp, bltriangle);
        *bltriangle->freq = 440;
        *bltriangle->amp = 0.5;
    }


    void start() {
        started = true;
    }

    void stop() {
        started = false;
    }

    void destroy() {
        sp_bltriangle_destroy(&bltriangle);
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


    void setParameter(AUParameterAddress address, AUValue value) {
        switch (address) {
            case frequencyAddress:
                frequencyRamper.set(clamp(value, (float)0.0, (float)20000.0));
                break;

            case amplitudeAddress:
                amplitudeRamper.set(clamp(value, (float)0.0, (float)1.0));
                break;

        }
    }

    AUValue getParameter(AUParameterAddress address) {
        switch (address) {
            case frequencyAddress:
                return frequencyRamper.goal();

            case amplitudeAddress:
                return amplitudeRamper.goal();

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

            *bltriangle->freq = frequency;
            *bltriangle->amp = amplitude;

            float temp = 0;
            for (int channel = 0; channel < channels; ++channel) {
                float *out = (float *)outBufferListPtr->mBuffers[channel].mData + frameOffset;
                if (started) {
                    if (channel == 0) {
                        sp_bltriangle_compute(sp, bltriangle, nil, &temp);
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
    sp_bltriangle *bltriangle;


    float frequency = 440;
    float amplitude = 0.5;

public:
    bool started = false;
    AKParameterRamper frequencyRamper = 440;
    AKParameterRamper amplitudeRamper = 0.5;
};

#endif /* AKTriangleOscillatorDSPKernel_hpp */
