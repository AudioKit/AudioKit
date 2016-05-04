//
//  AKMorphingOscillatorDSPKernel.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKMorphingOscillatorDSPKernel_hpp
#define AKMorphingOscillatorDSPKernel_hpp

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

class AKMorphingOscillatorDSPKernel : public DSPKernel {
public:
    // MARK: Member Functions

    AKMorphingOscillatorDSPKernel() {}

    void init(int channelCount, double inSampleRate) {
        channels = channelCount;

        sampleRate = float(inSampleRate);

        sp_create(&sp);
        sp->sr = sampleRate;
        sp->nchan = channels;
        sp_oscmorph_create(&oscmorph);

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
        sp_destroy(&sp);
    }

    void reset() {
        sp_oscmorph_init(sp, oscmorph, ft_array, 4, 0);
        oscmorph->freq = 440;
        oscmorph->amp = 0.5;
        oscmorph->wtpos = 0.0;
        resetted = true;
    }

    void setFrequency(float freq) {
        frequency = freq;
        frequencyRamper.setImmediate(freq);
    }

    void setAmplitude(float amp) {
        amplitude = amp;
        amplitudeRamper.setImmediate(amp);
    }

    void setIndex(float wtpos) {
        index = wtpos;
        indexRamper.setImmediate(wtpos);
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
                frequencyRamper.setUIValue(clamp(value, (float)0, (float)22050));
                break;

            case amplitudeAddress:
                amplitudeRamper.setUIValue(clamp(value, (float)0, (float)1));
                break;

            case indexAddress:
                indexRamper.setUIValue(clamp(value, (float)0.0, (float)1000.0));
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
                frequencyRamper.startRamp(clamp(value, (float)0, (float)22050), duration);
                break;

            case amplitudeAddress:
                amplitudeRamper.startRamp(clamp(value, (float)0, (float)1), duration);
                break;

            case indexAddress:
                indexRamper.startRamp(clamp(value, (float)0.0, (float)1000.0), duration);
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
        // For each sample.

        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            int frameOffset = int(frameIndex + bufferOffset);

            oscmorph->freq = frequencyRamper.getAndStep() * detuningMultiplier + detuningOffset;
            oscmorph->amp = amplitudeRamper.getAndStep();
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

    int channels = AKSettings.numberOfChannels;
    float sampleRate = AKSettings.sampleRate;

    AudioBufferList *outBufferListPtr = nullptr;

    sp_data *sp;
    sp_oscmorph *oscmorph;
    
    sp_ftbl *ftbl0;
    sp_ftbl *ftbl1;
    sp_ftbl *ftbl2;
    sp_ftbl *ftbl3;
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

#endif /* AKMorphingOscillatorDSPKernel_hpp */
