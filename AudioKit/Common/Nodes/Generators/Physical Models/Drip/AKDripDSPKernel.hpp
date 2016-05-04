//
//  AKDripDSPKernel.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKDripDSPKernel_hpp
#define AKDripDSPKernel_hpp

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

class AKDripDSPKernel : public DSPKernel {
public:
    // MARK: Member Functions

    AKDripDSPKernel() {}

    void init(int channelCount, double inSampleRate) {
        channels = channelCount;

        sampleRate = float(inSampleRate);

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
    }

    void setIntensity(float num_tubes) {
        intensity = num_tubes;
        intensityRamper.setImmediate(num_tubes);
    }

    void setDampingFactor(float damp) {
        dampingFactor = damp;
        dampingFactorRamper.setImmediate(damp);
    }

    void setEnergyReturn(float shake_max) {
        energyReturn = shake_max;
        energyReturnRamper.setImmediate(shake_max);
    }

    void setMainResonantFrequency(float freq) {
        mainResonantFrequency = freq;
        mainResonantFrequencyRamper.setImmediate(freq);
    }

    void setFirstResonantFrequency(float freq1) {
        firstResonantFrequency = freq1;
        firstResonantFrequencyRamper.setImmediate(freq1);
    }

    void setSecondResonantFrequency(float freq2) {
        secondResonantFrequency = freq2;
        secondResonantFrequencyRamper.setImmediate(freq2);
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
            case intensityAddress:
                intensityRamper.setUIValue(clamp(value, (float)0, (float)100));
                break;

            case dampingFactorAddress:
                dampingFactorRamper.setUIValue(clamp(value, (float)0.0, (float)2.0));
                break;

            case energyReturnAddress:
                energyReturnRamper.setUIValue(clamp(value, (float)0, (float)100));
                break;

            case mainResonantFrequencyAddress:
                mainResonantFrequencyRamper.setUIValue(clamp(value, (float)0, (float)22000));
                break;

            case firstResonantFrequencyAddress:
                firstResonantFrequencyRamper.setUIValue(clamp(value, (float)0, (float)22000));
                break;

            case secondResonantFrequencyAddress:
                secondResonantFrequencyRamper.setUIValue(clamp(value, (float)0, (float)22000));
                break;

            case amplitudeAddress:
                amplitudeRamper.setUIValue(clamp(value, (float)0, (float)1));
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
                intensityRamper.startRamp(clamp(value, (float)0, (float)100), duration);
                break;

            case dampingFactorAddress:
                dampingFactorRamper.startRamp(clamp(value, (float)0.0, (float)2.0), duration);
                break;

            case energyReturnAddress:
                energyReturnRamper.startRamp(clamp(value, (float)0, (float)100), duration);
                break;

            case mainResonantFrequencyAddress:
                mainResonantFrequencyRamper.startRamp(clamp(value, (float)0, (float)22000), duration);
                break;

            case firstResonantFrequencyAddress:
                firstResonantFrequencyRamper.startRamp(clamp(value, (float)0, (float)22000), duration);
                break;

            case secondResonantFrequencyAddress:
                secondResonantFrequencyRamper.startRamp(clamp(value, (float)0, (float)22000), duration);
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
        // For each sample.
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

    int channels = AKSettings.numberOfChannels;
    float sampleRate = AKSettings.sampleRate;
    float internalTrigger = 0;
    
    AudioBufferList *inBufferListPtr = nullptr;
    AudioBufferList *outBufferListPtr = nullptr;

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

#endif /* AKDripDSPKernel_hpp */
