//
//  AKMorphingOscillatorDSPKernel.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKMorphingOscillatorDSPKernel_hpp
#define AKMorphingOscillatorDSPKernel_hpp

#import "AKDSPKernel.hpp"
#import "AKParameterRamper.hpp"

extern "C" {
#include "soundpipe.h"
}

enum {
    frequencyAddress = 0,
    amplitudeAddress = 1,
    indexAddress = 2
};

class AKMorphingOscillatorDSPKernel : public AKDSPKernel {
public:
    // MARK: Member Functions

    AKMorphingOscillatorDSPKernel() {}

    void init(int channelCount, double inSampleRate) {
        channels = channelCount;

        sampleRate = float(inSampleRate);

        sp_create(&sp);
        sp_oscmorph_create(&oscmorph);
        sp_oscmorph_init(sp, oscmorph, ft_array, 4, 0);
        oscmorph->freq = 440;
        oscmorph->amp = 0.5;
        oscmorph->wtpos = 0.0;
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
    }

    void setFrequency(float freq) {
        frequency = freq;
        frequencyRamper.set(clamp(freq, (float)0, (float)22050));
    }

    void setAmplitude(float amp) {
        amplitude = amp;
        amplitudeRamper.set(clamp(amp, (float)0, (float)1));
    }

    void setIndex(float wtpos) {
        index = wtpos;
        indexRamper.set(clamp(wtpos, (float)0.0, (float)1000.0));
    }


    void setParameter(AUParameterAddress address, AUValue value) {
        switch (address) {
            case frequencyAddress:
                frequencyRamper.set(clamp(value, (float)0, (float)22050));
                break;

            case amplitudeAddress:
                amplitudeRamper.set(clamp(value, (float)0, (float)1));
                break;

            case indexAddress:
                indexRamper.set(clamp(value, (float)0.0, (float)1000.0));
                break;

        }
    }

    AUValue getParameter(AUParameterAddress address) {
        switch (address) {
            case frequencyAddress:
                return frequencyRamper.goal();

            case amplitudeAddress:
                return amplitudeRamper.goal();

            case indexAddress:
                return indexRamper.goal();

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

        }
    }

    void setBuffers(AudioBufferList *outBufferList) {
        outBufferListPtr = outBufferList;
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {
        // For each sample.
        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            int frameOffset = int(frameIndex + bufferOffset);

            oscmorph->freq = frequencyRamper.getStep();
            oscmorph->amp = amplitudeRamper.getStep();
            oscmorph->wtpos = indexRamper.getStep();

            float temp = 0;
            for (int channel = 0; channel < channels; ++channel) {
                float *out = (float *)outBufferListPtr->mBuffers[channel].mData + frameOffset;
                if (started) {
                    if (channel == 0) {
                        sp_oscmorph_compute(sp, oscmorph, nil, out);
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
    sp_oscmorph *oscmorph;
    
    sp_ftbl *ft_array[4];
    UInt32 tbl_size = 4096;

    float frequency = 440;
    float amplitude = 0.5;
    float index = 0.0;

public:
    bool started = true;
    AKParameterRamper frequencyRamper = 440;
    AKParameterRamper amplitudeRamper = 0.5;
    AKParameterRamper indexRamper = 0.0;
};

#endif /* AKMorphingOscillatorDSPKernel_hpp */
