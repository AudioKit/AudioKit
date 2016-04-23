//
//  AKBandRejectButterworthFilterDSPKernel.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKBandRejectButterworthFilterDSPKernel_hpp
#define AKBandRejectButterworthFilterDSPKernel_hpp

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

class AKBandRejectButterworthFilterDSPKernel : public DSPKernel {
public:
    // MARK: Member Functions

    AKBandRejectButterworthFilterDSPKernel() {}

    void init(int channelCount, double inSampleRate) {
        channels = channelCount;

        sampleRate = float(inSampleRate);

        sp_create(&sp);
        sp->sr = sampleRate;
        sp->nchan = channels;
        sp_butbr_create(&butbr);
        sp_butbr_init(sp, butbr);
        butbr->freq = 3000;
        butbr->bw = 2000;
    }

    void start() {
        started = true;
    }

    void stop() {
        started = false;
    }

    void destroy() {
        sp_butbr_destroy(&butbr);
        sp_destroy(&sp);
    }

    void reset() {
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
            double centerFrequency = double(centerFrequencyRamper.getAndStep());
            double bandwidth = double(bandwidthRamper.getAndStep());

            int frameOffset = int(frameIndex + bufferOffset);

            butbr->freq = (float)centerFrequency;
            butbr->bw = (float)bandwidth;

            if (!started) {
                outBufferListPtr->mBuffers[0] = inBufferListPtr->mBuffers[0];
                outBufferListPtr->mBuffers[1] = inBufferListPtr->mBuffers[1];
                return;
            }
            for (int channel = 0; channel < channels; ++channel) {
                float *in  = (float *)inBufferListPtr->mBuffers[channel].mData  + frameOffset;
                float *out = (float *)outBufferListPtr->mBuffers[channel].mData + frameOffset;

                sp_butbr_compute(sp, butbr, in, out);
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
    sp_butbr *butbr;

public:
    bool started = true;
    ParameterRamper centerFrequencyRamper = 3000;
    ParameterRamper bandwidthRamper = 2000;
};

#endif /* AKBandRejectButterworthFilterDSPKernel_hpp */
