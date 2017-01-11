//
//  AKBandPassButterworthFilterDSPKernel.hpp
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
    centerFrequencyAddress = 0,
    bandwidthAddress = 1
};

class AKBandPassButterworthFilterDSPKernel : public AKDSPKernel {
public:
    // MARK: Member Functions

    AKBandPassButterworthFilterDSPKernel() {}

    void init(int channelCount, double inSampleRate) {
        channels = channelCount;

        sampleRate = float(inSampleRate);

        sp_create(&sp);
        sp->sr = sampleRate;
        sp->nchan = channels;
        sp_butbp_create(&butbp);
        sp_butbp_init(sp, butbp);
        butbp->freq = 2000.0;
        butbp->bw = 100.0;

        centerFrequencyRamper.init();
        bandwidthRamper.init();
    }

    void start() {
        started = true;
    }

    void stop() {
        started = false;
    }

    void destroy() {
        sp_butbp_destroy(&butbp);
        sp_destroy(&sp);
    }

    void reset() {
        resetted = true;
        centerFrequencyRamper.reset();
        bandwidthRamper.reset();
    }

    void setCenterFrequency(float value) {
        centerFrequency = clamp(value, 12.0f, 20000.0f);
        centerFrequencyRamper.setImmediate(centerFrequency);
    }

    void setBandwidth(float value) {
        bandwidth = clamp(value, 0.0f, 20000.0f);
        bandwidthRamper.setImmediate(bandwidth);
    }


    void setParameter(AUParameterAddress address, AUValue value) {
        switch (address) {
            case centerFrequencyAddress:
                centerFrequencyRamper.setUIValue(clamp(value, 12.0f, 20000.0f));
                break;

            case bandwidthAddress:
                bandwidthRamper.setUIValue(clamp(value, 0.0f, 20000.0f));
                break;

        }
    }

    AUValue getParameter(AUParameterAddress address) {
        switch (address) {
            case centerFrequencyAddress:
                return centerFrequencyRamper.getUIValue();

            case bandwidthAddress:
                return bandwidthRamper.getUIValue();

            default: return 0.0f;
        }
    }

    void startRamp(AUParameterAddress address, AUValue value, AUAudioFrameCount duration) override {
        switch (address) {
            case centerFrequencyAddress:
                centerFrequencyRamper.startRamp(clamp(value, 12.0f, 20000.0f), duration);
                break;

            case bandwidthAddress:
                bandwidthRamper.startRamp(clamp(value, 0.0f, 20000.0f), duration);
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
            butbp->freq = (float)centerFrequency;
            bandwidth = bandwidthRamper.getAndStep();
            butbp->bw = (float)bandwidth;

            for (int channel = 0; channel < channels; ++channel) {
                float *in  = (float *)inBufferListPtr->mBuffers[channel].mData  + frameOffset;
                float *out = (float *)outBufferListPtr->mBuffers[channel].mData + frameOffset;

                if (started) {
                    sp_butbp_compute(sp, butbp, in, out);
                } else {
                    *out = *in;
                }
            }
        }
    }

    // MARK: Member Variables

private:

    AudioBufferList *inBufferListPtr = nullptr;
    AudioBufferList *outBufferListPtr = nullptr;

    sp_data *sp;
    sp_butbp *butbp;

    float centerFrequency = 2000.0;
    float bandwidth = 100.0;

public:
    bool started = true;
    bool resetted = false;
    ParameterRamper centerFrequencyRamper = 2000.0;
    ParameterRamper bandwidthRamper = 100.0;
};

