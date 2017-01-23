//
//  AKFMOscillatorDSPKernel.hpp
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
    baseFrequencyAddress = 0,
    carrierMultiplierAddress = 1,
    modulatingMultiplierAddress = 2,
    modulationIndexAddress = 3,
    amplitudeAddress = 4
};

class AKFMOscillatorDSPKernel : public AKSporthKernel, public AKOutputBuffered {
public:
    // MARK: Member Functions

    AKFMOscillatorDSPKernel() {}

    void init(int _channels, double _sampleRate) override {
        AKSporthKernel::init(_channels, _sampleRate);

        sp_fosc_create(&fosc);
        sp_fosc_init(sp, fosc, ftbl);
        
        fosc->freq = 440;
        fosc->car = 1.0;
        fosc->mod = 1;
        fosc->indx = 1;
        fosc->amp = 1;

        baseFrequencyRamper.init();
        carrierMultiplierRamper.init();
        modulatingMultiplierRamper.init();
        modulationIndexRamper.init();
        amplitudeRamper.init();
    }
    void setupWaveform(uint32_t size) {
        ftbl_size = size;
        sp_ftbl_create(sp, &ftbl, ftbl_size);
    }

    void setWaveformValue(uint32_t index, float value) {
        ftbl->tbl[index] = value;
    }

    void start() {
        started = true;
    }

    void stop() {
        started = false;
    }

    void destroy() {
        sp_fosc_destroy(&fosc);
        AKSporthKernel::destroy();
    }

    void reset() {
        resetted = true;
        baseFrequencyRamper.reset();
        carrierMultiplierRamper.reset();
        modulatingMultiplierRamper.reset();
        modulationIndexRamper.reset();
        amplitudeRamper.reset();
    }

    void setBaseFrequency(float value) {
        baseFrequency = clamp(value, 0.0f, 20000.0f);
        baseFrequencyRamper.setImmediate(baseFrequency);
    }

    void setCarrierMultiplier(float value) {
        carrierMultiplier = clamp(value, 0.0f, 1000.0f);
        carrierMultiplierRamper.setImmediate(carrierMultiplier);
    }

    void setModulatingMultiplier(float value) {
        modulatingMultiplier = clamp(value, 0.0f, 1000.0f);
        modulatingMultiplierRamper.setImmediate(modulatingMultiplier);
    }

    void setModulationIndex(float value) {
        modulationIndex = clamp(value, 0.0f, 1000.0f);
        modulationIndexRamper.setImmediate(modulationIndex);
    }

    void setAmplitude(float value) {
        amplitude = clamp(value, 0.0f, 10.0f);
        amplitudeRamper.setImmediate(amplitude);
    }


    void setParameter(AUParameterAddress address, AUValue value) {
        switch (address) {
            case baseFrequencyAddress:
                baseFrequencyRamper.setUIValue(clamp(value, 0.0f, 20000.0f));
                break;

            case carrierMultiplierAddress:
                carrierMultiplierRamper.setUIValue(clamp(value, 0.0f, 1000.0f));
                break;

            case modulatingMultiplierAddress:
                modulatingMultiplierRamper.setUIValue(clamp(value, 0.0f, 1000.0f));
                break;

            case modulationIndexAddress:
                modulationIndexRamper.setUIValue(clamp(value, 0.0f, 1000.0f));
                break;

            case amplitudeAddress:
                amplitudeRamper.setUIValue(clamp(value, 0.0f, 10.0f));
                break;

        }
    }

    AUValue getParameter(AUParameterAddress address) {
        switch (address) {
            case baseFrequencyAddress:
                return baseFrequencyRamper.getUIValue();

            case carrierMultiplierAddress:
                return carrierMultiplierRamper.getUIValue();

            case modulatingMultiplierAddress:
                return modulatingMultiplierRamper.getUIValue();

            case modulationIndexAddress:
                return modulationIndexRamper.getUIValue();

            case amplitudeAddress:
                return amplitudeRamper.getUIValue();

            default: return 0.0f;
        }
    }

    void startRamp(AUParameterAddress address, AUValue value, AUAudioFrameCount duration) override {
        switch (address) {
            case baseFrequencyAddress:
                baseFrequencyRamper.startRamp(clamp(value, 0.0f, 20000.0f), duration);
                break;

            case carrierMultiplierAddress:
                carrierMultiplierRamper.startRamp(clamp(value, 0.0f, 1000.0f), duration);
                break;

            case modulatingMultiplierAddress:
                modulatingMultiplierRamper.startRamp(clamp(value, 0.0f, 1000.0f), duration);
                break;

            case modulationIndexAddress:
                modulationIndexRamper.startRamp(clamp(value, 0.0f, 1000.0f), duration);
                break;

            case amplitudeAddress:
                amplitudeRamper.startRamp(clamp(value, 0.0f, 10.0f), duration);
                break;

        }
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {

        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {

            int frameOffset = int(frameIndex + bufferOffset);

            baseFrequency = double(baseFrequencyRamper.getAndStep());
            carrierMultiplier = double(carrierMultiplierRamper.getAndStep());
            modulatingMultiplier = double(modulatingMultiplierRamper.getAndStep());
            modulationIndex = double(modulationIndexRamper.getAndStep());
            amplitude = double(amplitudeRamper.getAndStep());

            fosc->freq = baseFrequency;
            fosc->car = carrierMultiplier;
            fosc->mod = modulatingMultiplier;
            fosc->indx = modulationIndex;
            fosc->amp = amplitude;

            float temp = 0;
            for (int channel = 0; channel < channels; ++channel) {
                float *out = (float *)outBufferListPtr->mBuffers[channel].mData + frameOffset;
                if (started) {
                    if (channel == 0) {
                        sp_fosc_compute(sp, fosc, nil, &temp);
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

    sp_fosc *fosc;
    sp_ftbl *ftbl;
    UInt32 ftbl_size = 4096;

    float baseFrequency = 440;
    float carrierMultiplier = 1.0;
    float modulatingMultiplier = 1;
    float modulationIndex = 1;
    float amplitude = 1;

public:
    bool started = false;
    bool resetted = false;
    ParameterRamper baseFrequencyRamper = 440;
    ParameterRamper carrierMultiplierRamper = 1.0;
    ParameterRamper modulatingMultiplierRamper = 1;
    ParameterRamper modulationIndexRamper = 1;
    ParameterRamper amplitudeRamper = 1;
};

