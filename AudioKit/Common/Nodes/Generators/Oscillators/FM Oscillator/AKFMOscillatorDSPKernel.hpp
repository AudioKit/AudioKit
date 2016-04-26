//
//  AKFMOscillatorDSPKernel.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKFMOscillatorDSPKernel_hpp
#define AKFMOscillatorDSPKernel_hpp

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

class AKFMOscillatorDSPKernel : public DSPKernel {
public:
    // MARK: Member Functions

    AKFMOscillatorDSPKernel() {}

    void init(int channelCount, double inSampleRate) {
        channels = channelCount;

        sampleRate = float(inSampleRate);

        sp_create(&sp);
        sp->sr = sampleRate;
        sp->nchan = channels;
        sp_fosc_create(&fosc);
        sp_fosc_init(sp, fosc, ftbl);
        
        fosc->freq = 440;
        fosc->car = 1.0;
        fosc->mod = 1;
        fosc->indx = 1;
        fosc->amp = 1;
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
        sp_destroy(&sp);
    }

    void reset() {
    }

    void setBaseFrequency(float freq) {
        baseFrequency = freq;
        baseFrequencyRamper.setUIValue(clamp(freq, (float)0.0, (float)20000.0));
    }

    void setCarrierMultiplier(float car) {
        carrierMultiplier = car;
        carrierMultiplierRamper.setUIValue(clamp(car, (float)0.0, (float)1000.0));
    }

    void setModulatingMultiplier(float mod) {
        modulatingMultiplier = mod;
        modulatingMultiplierRamper.setUIValue(clamp(mod, (float)0, (float)1000));
    }

    void setModulationIndex(float indx) {
        modulationIndex = indx;
        modulationIndexRamper.setUIValue(clamp(indx, (float)0, (float)1000));
    }

    void setAmplitude(float amp) {
        amplitude = amp;
        amplitudeRamper.setUIValue(clamp(amp, (float)0, (float)10));
    }


    void setParameter(AUParameterAddress address, AUValue value) {
        switch (address) {
            case baseFrequencyAddress:
                baseFrequencyRamper.setUIValue(clamp(value, (float)0.0, (float)20000.0));
                break;

            case carrierMultiplierAddress:
                carrierMultiplierRamper.setUIValue(clamp(value, (float)0.0, (float)1000.0));
                break;

            case modulatingMultiplierAddress:
                modulatingMultiplierRamper.setUIValue(clamp(value, (float)0, (float)1000));
                break;

            case modulationIndexAddress:
                modulationIndexRamper.setUIValue(clamp(value, (float)0, (float)1000));
                break;

            case amplitudeAddress:
                amplitudeRamper.setUIValue(clamp(value, (float)0, (float)10));
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
                baseFrequencyRamper.startRamp(clamp(value, (float)0.0, (float)20000.0), duration);
                break;

            case carrierMultiplierAddress:
                carrierMultiplierRamper.startRamp(clamp(value, (float)0.0, (float)1000.0), duration);
                break;

            case modulatingMultiplierAddress:
                modulatingMultiplierRamper.startRamp(clamp(value, (float)0, (float)1000), duration);
                break;

            case modulationIndexAddress:
                modulationIndexRamper.startRamp(clamp(value, (float)0, (float)1000), duration);
                break;

            case amplitudeAddress:
                amplitudeRamper.startRamp(clamp(value, (float)0, (float)10), duration);
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

    int channels = AKSettings.numberOfChannels;
    float sampleRate = AKSettings.sampleRate;

    AudioBufferList *outBufferListPtr = nullptr;

    sp_data *sp;
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
    ParameterRamper baseFrequencyRamper = 220;
    ParameterRamper carrierMultiplierRamper = 1.0;
    ParameterRamper modulatingMultiplierRamper = 1;
    ParameterRamper modulationIndexRamper = 1;
    ParameterRamper amplitudeRamper = 1;
};

#endif /* AKFMOscillatorDSPKernel_hpp */
