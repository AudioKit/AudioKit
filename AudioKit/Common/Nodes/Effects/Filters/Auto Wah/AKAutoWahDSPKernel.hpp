//
//  AKAutoWahDSPKernel.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKAutoWahDSPKernel_hpp
#define AKAutoWahDSPKernel_hpp

#import "DSPKernel.hpp"
#import "ParameterRamper.hpp"

#import <AudioKit/AudioKit-Swift.h>

extern "C" {
#include "soundpipe.h"
}

enum {
    wahAddress = 0,
    mixAddress = 1,
    amplitudeAddress = 2
};

class AKAutoWahDSPKernel : public DSPKernel {
public:
    // MARK: Member Functions

    AKAutoWahDSPKernel() {}

    void init(int channelCount, double inSampleRate) {
        channels = channelCount;

        sampleRate = float(inSampleRate);

        sp_create(&sp);
        sp->sr = sampleRate;
        sp->nchan = channels;
        sp_autowah_create(&autowah);
        sp_autowah_init(sp, autowah);
        *autowah->wah = 0;
        *autowah->mix = 100;
        *autowah->level = 0.1;
    }

    void start() {
        started = true;
    }

    void stop() {
        started = false;
    }

    void destroy() {
        sp_autowah_destroy(&autowah);
        sp_destroy(&sp);
    }

    void reset() {
        resetted = true;
    }

    void setWah(float wah) {
        wah = wah;
        wahRamper.setImmediate(wah);
    }

    void setMix(float mix) {
        mix = mix;
        mixRamper.setImmediate(mix);
    }

    void setAmplitude(float level) {
        amplitude = level;
        amplitudeRamper.setImmediate(level);
    }


    void setParameter(AUParameterAddress address, AUValue value) {
        switch (address) {
            case wahAddress:
                wahRamper.setUIValue(clamp(value, (float)0, (float)1));
                break;

            case mixAddress:
                mixRamper.setUIValue(clamp(value, (float)0, (float)100));
                break;

            case amplitudeAddress:
                amplitudeRamper.setUIValue(clamp(value, (float)0, (float)1));
                break;

        }
    }

    AUValue getParameter(AUParameterAddress address) {
        switch (address) {
            case wahAddress:
                return wahRamper.getUIValue();

            case mixAddress:
                return mixRamper.getUIValue();

            case amplitudeAddress:
                return amplitudeRamper.getUIValue();

            default: return 0.0f;
        }
    }

    void startRamp(AUParameterAddress address, AUValue value, AUAudioFrameCount duration) override {
        switch (address) {
            case wahAddress:
                wahRamper.startRamp(clamp(value, (float)0, (float)1), duration);
                break;

            case mixAddress:
                mixRamper.startRamp(clamp(value, (float)0, (float)100), duration);
                break;

            case amplitudeAddress:
                amplitudeRamper.startRamp(clamp(value, (float)0, (float)1), duration);
                break;

        }
    }

    void setBuffers(AudioBufferList *inBufferList, AudioBufferList *outBufferList) {
        inBufferListPtr = inBufferList;
        outBufferListPtr = outBufferList;
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {

        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {

            int frameOffset = int(frameIndex + bufferOffset);

            wah = wahRamper.getAndStep();
            *autowah->wah = (float)wah;
            mix = mixRamper.getAndStep();
            *autowah->mix = (float)mix;
            amplitude = amplitudeRamper.getAndStep();
            *autowah->level = (float)amplitude;

            for (int channel = 0; channel < channels; ++channel) {
                float *in  = (float *)inBufferListPtr->mBuffers[channel].mData  + frameOffset;
                float *out = (float *)outBufferListPtr->mBuffers[channel].mData + frameOffset;
                
                if (started) {
                    sp_autowah_compute(sp, autowah, in, out);
                } else {
                    *out = *in;
                }
            }
        }
    }

    // MARK: Member Variables

private:

    int channels = AKSettings.numberOfChannels;
    float sampleRate = AKSettings.sampleRate;

    AudioBufferList *inBufferListPtr = nullptr;
    AudioBufferList *outBufferListPtr = nullptr;

    sp_data *sp;
    sp_autowah *autowah;

    float wah = 0;
    float mix = 100;
    float amplitude = 0.1;

public:
    bool started = true;
    bool resetted = false;
    ParameterRamper wahRamper = 0;
    ParameterRamper mixRamper = 100;
    ParameterRamper amplitudeRamper = 0.1;
};

#endif /* AKAutoWahDSPKernel_hpp */
