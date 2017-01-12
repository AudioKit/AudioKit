//
//  AKPhaseDistortionOscillatorDSPKernel.hpp
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
    phaseDistortionAddress = 2,
    detuningOffsetAddress = 3,
    detuningMultiplierAddress = 4
};

class AKPhaseDistortionOscillatorDSPKernel : public AKDSPKernel, AKOutputBuffered {
public:
    // MARK: Member Functions

    AKPhaseDistortionOscillatorDSPKernel() {}

    void init(int channelCount, double inSampleRate) {
        channels = channelCount;

        sampleRate = float(inSampleRate);

        sp_create(&sp);
        sp->sr = sampleRate;
        sp->nchan = channels;

        sp_pdhalf_create(&pdhalf);
        sp_tabread_create(&tab);
        sp_tabread_init(sp, tab, ftbl, 1);
        sp_phasor_create(&phs);
        
        sp_pdhalf_init(sp, pdhalf);
        sp_phasor_init(sp, phs, 0);
        
        phs->freq = 440;
        pdhalf->amount = 0.0;

        frequencyRamper.init();
        amplitudeRamper.init();
        phaseDistortionRamper.init();
        detuningOffsetRamper.init();
        detuningMultiplierRamper.init();
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
        sp_pdhalf_destroy(&pdhalf);
        sp_ftbl_destroy(&ftbl);
        sp_tabread_destroy(&tab);
        sp_phasor_destroy(&phs);
        sp_destroy(&sp);
    }

    void reset() {
        resetted = true;

        frequencyRamper.reset();
        amplitudeRamper.reset();
        phaseDistortionRamper.reset();
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
        detuningMultiplier = clamp(value, 0.5f, 2.0f);
        detuningMultiplierRamper.setImmediate(detuningMultiplier);
    }
    
    void setPhaseDistortion(float value) {
        phaseDistortion = clamp(value, -1.0f, 1.0f);
        phaseDistortionRamper.setImmediate(phaseDistortion);
    }


    void setParameter(AUParameterAddress address, AUValue value) {
        switch (address) {
            case frequencyAddress:
                frequencyRamper.setUIValue(clamp(value, 0.0f, 20000.0f));
                break;

            case amplitudeAddress:
                amplitudeRamper.setUIValue(clamp(value, 0.0f, 10.0f));
                break;

            case phaseDistortionAddress:
                phaseDistortionRamper.setUIValue(clamp(value, -1.0f, 1.0f));
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

            case phaseDistortionAddress:
                return phaseDistortionRamper.getUIValue();

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

            case phaseDistortionAddress:
                phaseDistortionRamper.startRamp(clamp(value, -1.0f, 1.0f), duration);
                break;

            case detuningOffsetAddress:
                detuningOffsetRamper.startRamp(clamp(value, -1000.0f, 1000.0f), duration);
                break;

            case detuningMultiplierAddress:
                detuningMultiplierRamper.startRamp(clamp(value, 0.5f, 2.0f), duration);
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
            phaseDistortion = double(phaseDistortionRamper.getAndStep());
            detuningOffset = double(detuningOffsetRamper.getAndStep());
            detuningMultiplier = double(detuningMultiplierRamper.getAndStep());

            phs->freq = frequency * detuningMultiplier + detuningOffset;
            pdhalf->amount = phaseDistortion;

            float temp = 0;
            float pd = 0;
            float ph = 0;
            for (int channel = 0; channel < channels; ++channel) {
                float *out = (float *)outBufferListPtr->mBuffers[channel].mData + frameOffset;
                if (started) {
                    if (channel == 0) {
                        sp_phasor_compute(sp, phs, NULL, &ph);
                        sp_pdhalf_compute(sp, pdhalf, &ph, &pd);
                        tab->index = pd;
                        sp_tabread_compute(sp, tab, NULL, &temp);
                    }
                    *out = temp * amplitude;
                } else {
                    *out = 0.0;
                }
            }
        }
    }

    // MARK: Member Variables

private:

    sp_data *sp;
    sp_ftbl *ftbl;
    sp_tabread *tab;
    sp_phasor *phs;
    sp_pdhalf *pdhalf;
    UInt32 ftbl_size = 4096;


    float frequency = 440;
    float amplitude = 1.0;
    float phaseDistortion = 0.0;
    float detuningOffset = 0;
    float detuningMultiplier = 1;

public:
    bool started = false;
    bool resetted = false;
    ParameterRamper frequencyRamper = 440;
    ParameterRamper amplitudeRamper = 1.0;
    ParameterRamper phaseDistortionRamper = 0.0;
    ParameterRamper detuningOffsetRamper = 0;
    ParameterRamper detuningMultiplierRamper = 1;
};

