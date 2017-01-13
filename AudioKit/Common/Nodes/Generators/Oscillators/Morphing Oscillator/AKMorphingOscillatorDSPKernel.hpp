//
//  AKMorphingOscillatorDSPKernel.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
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
    indexAddress = 2,
    detuningOffsetAddress = 3,
    detuningMultiplierAddress = 4
};

class AKMorphingOscillatorDSPKernel : public AKSporthKernel, public AKOutputBuffered {
public:
    // MARK: Member Functions

    AKMorphingOscillatorDSPKernel() {}

    void init(int channelCount, double inSampleRate) {
        AKSporthKernel::init(channelCount, inSampleRate);

        sp_oscmorph_create(&oscmorph);

        frequencyRamper.init();
        amplitudeRamper.init();
        indexRamper.init();
        detuningOffsetRamper.init();
        detuningMultiplierRamper.init();
    }

    void setupWaveform(uint32_t waveform, uint32_t size) {
        tbl_size = size;
        sp_ftbl_create(sp, &ft_array[waveform], tbl_size);
    }

    void setWaveformValue(uint32_t waveform, uint32_t index, float value) {
        ft_array[waveform]->tbl[index] = value;
    }

    void start() {
        started = true;
    }

    void stop() {
        started = false;
    }

    void destroy() {
        sp_oscmorph_destroy(&oscmorph);
        AKSporthKernel::destroy();
    }

    void reset() {
        sp_oscmorph_init(sp, oscmorph, ft_array, 4, 0);
        oscmorph->freq = 440;
        oscmorph->amp = 0.5;
        oscmorph->wtpos = 0.0;
        resetted = true;
        frequencyRamper.reset();
        amplitudeRamper.reset();
        indexRamper.reset();
        detuningOffsetRamper.reset();
        detuningMultiplierRamper.reset();
    }

    void setFrequency(float value) {
        frequency = clamp(value, 0.0f, 22050.0f);
        frequencyRamper.setImmediate(frequency);
    }

    void setAmplitude(float value) {
        amplitude = clamp(value, 0.0f, 1.0f);
        amplitudeRamper.setImmediate(amplitude);
    }

    void setIndex(float value) {
        index = clamp(value, 0.0f, 1000.0f);
        indexRamper.setImmediate(index);
    }

    void setDetuningOffset(float value) {
        detuningOffset = clamp(value, -1000.0f, 1000.0f);
        detuningOffsetRamper.setImmediate(detuningOffset);
    }

    void setDetuningMultiplier(float value) {
        detuningMultiplier = clamp(value, 0.5f, 2.0f);
        detuningMultiplierRamper.setImmediate(detuningMultiplier);
    }


    void setParameter(AUParameterAddress address, AUValue value) {
        switch (address) {
            case frequencyAddress:
                frequencyRamper.setUIValue(clamp(value, 0.0f, 22050.0f));
                break;

            case amplitudeAddress:
                amplitudeRamper.setUIValue(clamp(value, 0.0f, 1.0f));
                break;

            case indexAddress:
                indexRamper.setUIValue(clamp(value, 0.0f, 1000.0f));
                break;

            case detuningOffsetAddress:
                detuningOffsetRamper.setUIValue(clamp(value, -1000.0f, 1000.0f));
                break;

            case detuningMultiplierAddress:
                detuningMultiplierRamper.setUIValue(clamp(value, 0.5f, 2.0f));
                break;

        }
    }

    AUValue getParameter(AUParameterAddress address) {
        switch (address) {
            case frequencyAddress:
                return frequencyRamper.getUIValue();

            case amplitudeAddress:
                return amplitudeRamper.getUIValue();

            case indexAddress:
                return indexRamper.getUIValue();

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
                frequencyRamper.startRamp(clamp(value, 0.0f, 22050.0f), duration);
                break;

            case amplitudeAddress:
                amplitudeRamper.startRamp(clamp(value, 0.0f, 1.0f), duration);
                break;

            case indexAddress:
                indexRamper.startRamp(clamp(value, 0.0f, 1000.0f), duration);
                break;

            case detuningOffsetAddress:
                detuningOffsetRamper.startRamp(clamp(value, -1000.0f, 1000.0f), duration);
                break;

            case detuningMultiplierAddress:
                detuningMultiplierRamper.startRamp(clamp(value, 0.5f, 2.0f), duration);
                break;

        }
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {

        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {

            int frameOffset = int(frameIndex + bufferOffset);

            frequency = double(frequencyRamper.getAndStep());
            amplitude = double(amplitudeRamper.getAndStep());
            detuningOffset = double(detuningOffsetRamper.getAndStep());
            detuningMultiplier = double(detuningMultiplierRamper.getAndStep());
            
            oscmorph->freq = frequency * detuningMultiplier + detuningOffset;
            oscmorph->amp = amplitude;
            oscmorph->wtpos = indexRamper.getAndStep();
            
            float temp = 0;
            for (int channel = 0; channel < channels; ++channel) {
                float *out = (float *)outBufferListPtr->mBuffers[channel].mData + frameOffset;

                if (started) {
                    if (channel == 0) {
                        sp_oscmorph_compute(sp, oscmorph, nil, &temp);
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

    sp_oscmorph *oscmorph;
    
    sp_ftbl *ft_array[4];
    UInt32 tbl_size = 4096;

    float frequency = 440;
    float amplitude = 0.5;
    float index = 0.0;
    float detuningOffset = 0.0;
    float detuningMultiplier = 1.0;

public:
    bool started = true;
    bool resetted = false;
    ParameterRamper frequencyRamper = 440;
    ParameterRamper amplitudeRamper = 0.5;
    ParameterRamper indexRamper = 0.0;
    ParameterRamper detuningOffsetRamper = 0.0;
    ParameterRamper detuningMultiplierRamper = 1.0;
};


