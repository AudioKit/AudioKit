//
//  AKPeakingParametricEqualizerFilterDSPKernel.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKPeakingParametricEqualizerFilterDSPKernel_hpp
#define AKPeakingParametricEqualizerFilterDSPKernel_hpp

#import "DSPKernel.hpp"
#import "ParameterRamper.hpp"

#import <AudioKit/AudioKit-Swift.h>

extern "C" {
#include "soundpipe.h"
}

enum {
    centerFrequencyAddress = 0,
    gainAddress = 1,
    qAddress = 2
};

class AKPeakingParametricEqualizerFilterDSPKernel : public DSPKernel {
public:
    // MARK: Member Functions

    AKPeakingParametricEqualizerFilterDSPKernel() {}

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
        pareq->mode = 0;

        centerFrequencyRamper.init();
        gainRamper.init();
        qRamper.init();
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
        resetted = true;
        centerFrequencyRamper.reset();
        gainRamper.reset();
        qRamper.reset();
    }

    void setCenterFrequency(float value) {
        centerFrequency = clamp(value, 12.0f, 20000.0f);
        centerFrequencyRamper.setImmediate(centerFrequency);
    }

    void setGain(float value) {
        gain = clamp(value, 0.0f, 10.0f);
        gainRamper.setImmediate(gain);
    }

    void setQ(float value) {
        q = clamp(value, 0.0f, 2.0f);
        qRamper.setImmediate(q);
    }


    void setParameter(AUParameterAddress address, AUValue value) {
        switch (address) {
            case centerFrequencyAddress:
                centerFrequencyRamper.setUIValue(clamp(value, 12.0f, 20000.0f));
                break;

            case gainAddress:
                gainRamper.setUIValue(clamp(value, 0.0f, 10.0f));
                break;

            case qAddress:
                qRamper.setUIValue(clamp(value, 0.0f, 2.0f));
                break;

        }
    }

    AUValue getParameter(AUParameterAddress address) {
        switch (address) {
            case centerFrequencyAddress:
                return centerFrequencyRamper.getUIValue();

            case gainAddress:
                return gainRamper.getUIValue();

            case qAddress:
                return qRamper.getUIValue();

            default: return 0.0f;
        }
    }

    void startRamp(AUParameterAddress address, AUValue value, AUAudioFrameCount duration) override {
        switch (address) {
            case centerFrequencyAddress:
                centerFrequencyRamper.startRamp(clamp(value, 12.0f, 20000.0f), duration);
                break;

            case gainAddress:
                gainRamper.startRamp(clamp(value, 0.0f, 10.0f), duration);
                break;

            case qAddress:
                qRamper.startRamp(clamp(value, 0.0f, 2.0f), duration);
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

            centerFrequency = centerFrequencyRamper.getAndStep();
            pareq->fc = (float)centerFrequency;
            gain = gainRamper.getAndStep();
            pareq->v = (float)gain;
            q = qRamper.getAndStep();
            pareq->q = (float)q;

            for (int channel = 0; channel < channels; ++channel) {
                float *in  = (float *)inBufferListPtr->mBuffers[channel].mData  + frameOffset;
                float *out = (float *)outBufferListPtr->mBuffers[channel].mData + frameOffset;

                if (started) {
                    sp_pareq_compute(sp, pareq, in, out);
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
    sp_pareq *pareq;

    float centerFrequency = 1000;
    float gain = 1.0;
    float q = 0.707;

public:
    bool started = true;
    bool resetted = false;
    ParameterRamper centerFrequencyRamper = 1000;
    ParameterRamper gainRamper = 1.0;
    ParameterRamper qRamper = 0.707;
};

#endif /* AKPeakingParametricEqualizerFilterDSPKernel_hpp */
