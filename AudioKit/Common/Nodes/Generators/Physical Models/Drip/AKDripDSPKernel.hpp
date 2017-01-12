//
//  AKDripDSPKernel.hpp
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
    intensityAddress = 0,
    dampingFactorAddress = 1,
    energyReturnAddress = 2,
    mainResonantFrequencyAddress = 3,
    firstResonantFrequencyAddress = 4,
    secondResonantFrequencyAddress = 5,
    amplitudeAddress = 6
};

class AKDripDSPKernel : public AKDSPKernel, public AKBuffered {
public:
    // MARK: Member Functions

    AKDripDSPKernel() {}

    void init(int channelCount, double inSampleRate) {
        AKDSPKernel::init(channelCount, inSampleRate);
        sp_create(&sp);
        sp->sr = sampleRate;
        sp->nchan = channels;
        sp_drip_create(&drip);
        sp_drip_init(sp, drip, 0.9);
        drip->num_tubes = 10;
        drip->damp = 0.2;
        drip->shake_max = 0;
        drip->freq = 450;
        drip->freq1 = 600;
        drip->freq2 = 750;
        drip->amp = 0.3;

        intensityRamper.init();
        dampingFactorRamper.init();
        energyReturnRamper.init();
        mainResonantFrequencyRamper.init();
        firstResonantFrequencyRamper.init();
        secondResonantFrequencyRamper.init();
        amplitudeRamper.init();
    }

    void start() {
        started = true;
    }

    void stop() {
        started = false;
    }

    void destroy() {
        sp_drip_destroy(&drip);
        sp_destroy(&sp);
    }

    void reset() {
        resetted = true;
        intensityRamper.reset();
        dampingFactorRamper.reset();
        energyReturnRamper.reset();
        mainResonantFrequencyRamper.reset();
        firstResonantFrequencyRamper.reset();
        secondResonantFrequencyRamper.reset();
        amplitudeRamper.reset();
    }

    void setIntensity(float value) {
        intensity = clamp(value, 0.0f, 100.0f);
        intensityRamper.setImmediate(intensity);
    }

    void setDampingFactor(float value) {
        dampingFactor = clamp(value, 0.0f, 2.0f);
        dampingFactorRamper.setImmediate(dampingFactor);
    }

    void setEnergyReturn(float value) {
        energyReturn = clamp(value, 0.0f, 100.0f);
        energyReturnRamper.setImmediate(energyReturn);
    }

    void setMainResonantFrequency(float value) {
        mainResonantFrequency = clamp(value, 0.0f, 22000.0f);
        mainResonantFrequencyRamper.setImmediate(mainResonantFrequency);
    }

    void setFirstResonantFrequency(float value) {
        firstResonantFrequency = clamp(value, 0.0f, 22000.0f);
        firstResonantFrequencyRamper.setImmediate(firstResonantFrequency);
    }

    void setSecondResonantFrequency(float value) {
        secondResonantFrequency = clamp(value, 0.0f, 22000.0f);
        secondResonantFrequencyRamper.setImmediate(secondResonantFrequency);
    }

    void setAmplitude(float value) {
        amplitude = clamp(value, 0.0f, 1.0f);
        amplitudeRamper.setImmediate(amplitude);
    }

    void trigger() {
        internalTrigger = 1;
    }

    void setParameter(AUParameterAddress address, AUValue value) {
        switch (address) {
            case intensityAddress:
                intensityRamper.setUIValue(clamp(value, 0.0f, 100.0f));
                break;

            case dampingFactorAddress:
                dampingFactorRamper.setUIValue(clamp(value, 0.0f, 2.0f));
                break;

            case energyReturnAddress:
                energyReturnRamper.setUIValue(clamp(value, 0.0f, 100.0f));
                break;

            case mainResonantFrequencyAddress:
                mainResonantFrequencyRamper.setUIValue(clamp(value, 0.0f, 22000.0f));
                break;

            case firstResonantFrequencyAddress:
                firstResonantFrequencyRamper.setUIValue(clamp(value, 0.0f, 22000.0f));
                break;

            case secondResonantFrequencyAddress:
                secondResonantFrequencyRamper.setUIValue(clamp(value, 0.0f, 22000.0f));
                break;

            case amplitudeAddress:
                amplitudeRamper.setUIValue(clamp(value, 0.0f, 1.0f));
                break;

        }
    }

    AUValue getParameter(AUParameterAddress address) {
        switch (address) {
            case intensityAddress:
                return intensityRamper.getUIValue();

            case dampingFactorAddress:
                return dampingFactorRamper.getUIValue();

            case energyReturnAddress:
                return energyReturnRamper.getUIValue();

            case mainResonantFrequencyAddress:
                return mainResonantFrequencyRamper.getUIValue();

            case firstResonantFrequencyAddress:
                return firstResonantFrequencyRamper.getUIValue();

            case secondResonantFrequencyAddress:
                return secondResonantFrequencyRamper.getUIValue();

            case amplitudeAddress:
                return amplitudeRamper.getUIValue();

            default: return 0.0f;
        }
    }

    void startRamp(AUParameterAddress address, AUValue value, AUAudioFrameCount duration) override {
        switch (address) {
            case intensityAddress:
                intensityRamper.startRamp(clamp(value, 0.0f, 100.0f), duration);
                break;

            case dampingFactorAddress:
                dampingFactorRamper.startRamp(clamp(value, 0.0f, 2.0f), duration);
                break;

            case energyReturnAddress:
                energyReturnRamper.startRamp(clamp(value, 0.0f, 100.0f), duration);
                break;

            case mainResonantFrequencyAddress:
                mainResonantFrequencyRamper.startRamp(clamp(value, 0.0f, 22000.0f), duration);
                break;

            case firstResonantFrequencyAddress:
                firstResonantFrequencyRamper.startRamp(clamp(value, 0.0f, 22000.0f), duration);
                break;

            case secondResonantFrequencyAddress:
                secondResonantFrequencyRamper.startRamp(clamp(value, 0.0f, 22000.0f), duration);
                break;

            case amplitudeAddress:
                amplitudeRamper.startRamp(clamp(value, 0.0f, 1.0f), duration);
                break;

        }
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {

        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {

            int frameOffset = int(frameIndex + bufferOffset);

            intensity = intensityRamper.getAndStep();
            drip->num_tubes = (float)intensity;
            dampingFactor = dampingFactorRamper.getAndStep();
            drip->damp = (float)dampingFactor;
            energyReturn = energyReturnRamper.getAndStep();
            drip->shake_max = (float)energyReturn;
            mainResonantFrequency = mainResonantFrequencyRamper.getAndStep();
            drip->freq = (float)mainResonantFrequency;
            firstResonantFrequency = firstResonantFrequencyRamper.getAndStep();
            drip->freq1 = (float)firstResonantFrequency;
            secondResonantFrequency = secondResonantFrequencyRamper.getAndStep();
            drip->freq2 = (float)secondResonantFrequency;
            amplitude = amplitudeRamper.getAndStep();
            drip->amp = (float)amplitude;

            for (int channel = 0; channel < channels; ++channel) {
                float *out = (float *)outBufferListPtr->mBuffers[channel].mData + frameOffset;
                if (started) {
                    sp_drip_compute(sp, drip, &internalTrigger, out);
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

    float internalTrigger = 0;

    sp_data *sp;
    sp_drip *drip;

    float intensity = 10;
    float dampingFactor = 0.2;
    float energyReturn = 0;
    float mainResonantFrequency = 450;
    float firstResonantFrequency = 600;
    float secondResonantFrequency = 750;
    float amplitude = 0.3;

public:
    bool started = false;
    bool resetted = false;
    ParameterRamper intensityRamper = 10;
    ParameterRamper dampingFactorRamper = 0.2;
    ParameterRamper energyReturnRamper = 0;
    ParameterRamper mainResonantFrequencyRamper = 450;
    ParameterRamper firstResonantFrequencyRamper = 600;
    ParameterRamper secondResonantFrequencyRamper = 750;
    ParameterRamper amplitudeRamper = 0.3;
};

