//
//  AKBandPassButterworthFilterDSPKernel.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKBandPassButterworthFilterDSPKernel_hpp
#define AKBandPassButterworthFilterDSPKernel_hpp

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

class AKBandPassButterworthFilterDSPKernel : public DSPKernel {
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
        butbp->freq = 2000;
        butbp->bw = 100;
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
    }

    void setCenterFrequency(float freq) {
        centerFrequency = freq;
        centerFrequencyRamper.setImmediate(freq);
    }

    void setBandwidth(float bw) {
        bandwidth = bw;
        bandwidthRamper.setImmediate(bw);
    }


    void setParameter(AUParameterAddress address, AUValue value) {
        switch (address) {
            case centerFrequencyAddress:
                centerFrequencyRamper.setUIValue(clamp(value, (float)12.0, (float)20000.0));
                break;

            case bandwidthAddress:
                bandwidthRamper.setUIValue(clamp(value, (float)0.0, (float)20000.0));
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
                centerFrequencyRamper.startRamp(clamp(value, (float)12.0, (float)20000.0), duration);
                break;

            case bandwidthAddress:
                bandwidthRamper.startRamp(clamp(value, (float)0.0, (float)20000.0), duration);
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

            int frameOffset = int(frameIndex + bufferOffset);

            centerFrequency = centerFrequencyRamper.getAndStep();
            butbp->freq = (float)centerFrequency;
            bandwidth = bandwidthRamper.getAndStep();
            butbp->bw = (float)bandwidth;

            if (!started) {
                outBufferListPtr->mBuffers[0] = inBufferListPtr->mBuffers[0];
                outBufferListPtr->mBuffers[1] = inBufferListPtr->mBuffers[1];
                return;
            }
            for (int channel = 0; channel < channels; ++channel) {
                float *in  = (float *)inBufferListPtr->mBuffers[channel].mData  + frameOffset;
                float *out = (float *)outBufferListPtr->mBuffers[channel].mData + frameOffset;

                sp_butbp_compute(sp, butbp, in, out);
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
    sp_butbp *butbp;

    float centerFrequency = 2000;
    float bandwidth = 100;

public:
    bool started = true;
    bool resetted = false;
    ParameterRamper centerFrequencyRamper = 2000;
    ParameterRamper bandwidthRamper = 100;
};

#endif /* AKBandPassButterworthFilterDSPKernel_hpp */
