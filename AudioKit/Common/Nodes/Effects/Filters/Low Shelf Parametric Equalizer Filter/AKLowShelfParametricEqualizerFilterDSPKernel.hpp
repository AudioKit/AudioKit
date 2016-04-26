//
//  AKLowShelfParametricEqualizerFilterDSPKernel.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKLowShelfParametricEqualizerFilterDSPKernel_hpp
#define AKLowShelfParametricEqualizerFilterDSPKernel_hpp

#import "DSPKernel.hpp"
#import "ParameterRamper.hpp"

#import <AudioKit/AudioKit-Swift.h>

extern "C" {
#include "soundpipe.h"
}

enum {
    cornerFrequencyAddress = 0,
    gainAddress = 1,
    qAddress = 2
};

class AKLowShelfParametricEqualizerFilterDSPKernel : public DSPKernel {
public:
    // MARK: Member Functions

    AKLowShelfParametricEqualizerFilterDSPKernel() {}

    void init(int channelCount, double inSampleRate) {
        channels = channelCount;

        sampleRate = float(inSampleRate);

        sp_create(&sp);
        sp->sr = sampleRate;
        sp->nchan = channels;
        sp_pareq_create(&pareq);
        sp_pareq_init(sp, pareq);
        pareq->fc = 1000;
        pareq->v = 1.0;
        pareq->q = 0.707;
        pareq->mode = 1;
    }

    void start() {
        started = true;
    }

    void stop() {
        started = false;
    }

    void destroy() {
        sp_pareq_destroy(&pareq);
        sp_destroy(&sp);
    }

    void reset() {
    }

    void setParameter(AUParameterAddress address, AUValue value) {
        switch (address) {
            case cornerFrequencyAddress:
                cornerFrequencyRamper.setUIValue(clamp(value, (float)12.0, (float)20000.0));
                break;

            case gainAddress:
                gainRamper.setUIValue(clamp(value, (float)0.0, (float)10.0));
                break;

            case qAddress:
                qRamper.setUIValue(clamp(value, (float)0.0, (float)2.0));
                break;

        }
    }

    AUValue getParameter(AUParameterAddress address) {
        switch (address) {
            case cornerFrequencyAddress:
                return cornerFrequencyRamper.getUIValue();

            case gainAddress:
                return gainRamper.getUIValue();

            case qAddress:
                return qRamper.getUIValue();

            default: return 0.0f;
        }
    }

    void startRamp(AUParameterAddress address, AUValue value, AUAudioFrameCount duration) override {
        switch (address) {
            case cornerFrequencyAddress:
                cornerFrequencyRamper.startRamp(clamp(value, (float)12.0, (float)20000.0), duration);
                break;

            case gainAddress:
                gainRamper.startRamp(clamp(value, (float)0.0, (float)10.0), duration);
                break;

            case qAddress:
                qRamper.startRamp(clamp(value, (float)0.0, (float)2.0), duration);
                break;

        }
    }

    void setBuffers(AudioBufferList *inBufferList, AudioBufferList *outBufferList) {
        inBufferListPtr = inBufferList;
        outBufferListPtr = outBufferList;
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {
        // For each sample.
        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            double cornerFrequency = double(cornerFrequencyRamper.getAndStep());
            double gain = double(gainRamper.getAndStep());
            double q = double(qRamper.getAndStep());

            int frameOffset = int(frameIndex + bufferOffset);

            pareq->fc = (float)cornerFrequency;
            pareq->v = (float)gain;
            pareq->q = (float)q;

            if (!started) {
                outBufferListPtr->mBuffers[0] = inBufferListPtr->mBuffers[0];
                outBufferListPtr->mBuffers[1] = inBufferListPtr->mBuffers[1];
                return;
            }
            for (int channel = 0; channel < channels; ++channel) {
                float *in  = (float *)inBufferListPtr->mBuffers[channel].mData  + frameOffset;
                float *out = (float *)outBufferListPtr->mBuffers[channel].mData + frameOffset;

                sp_pareq_compute(sp, pareq, in, out);
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
    sp_pareq *pareq;

public:
    bool started = true;
    ParameterRamper cornerFrequencyRamper = 1000;
    ParameterRamper gainRamper = 1.0;
    ParameterRamper qRamper = 0.707;
};

#endif /* AKLowShelfParametricEqualizerFilterDSPKernel_hpp */
