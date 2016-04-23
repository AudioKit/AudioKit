//
//  AKEqualizerFilterDSPKernel.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKEqualizerFilterDSPKernel_hpp
#define AKEqualizerFilterDSPKernel_hpp

#import "AKDSPKernel.hpp"
#import "AKParameterRamper.hpp"

#import <AudioKit/AudioKit-Swift.h>

extern "C" {
#include "soundpipe.h"
}

enum {
    centerFrequencyAddress = 0,
    bandwidthAddress = 1,
    gainAddress = 2
};

class AKEqualizerFilterDSPKernel : public AKDSPKernel {
public:
    // MARK: Member Functions

    AKEqualizerFilterDSPKernel() {}

    void init(int channelCount, double inSampleRate) {
        channels = channelCount;

        sampleRate = float(inSampleRate);

        sp_create(&sp);
        sp->sr = sampleRate;
        sp->nchan = channels;
        sp_eqfil_create(&eqfil);
        sp_eqfil_init(sp, eqfil);
        eqfil->freq = 1000;
        eqfil->bw = 100;
        eqfil->gain = 10;
    }

    void start() {
        started = true;
    }

    void stop() {
        started = false;
    }

    void destroy() {
        sp_eqfil_destroy(&eqfil);
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

            case gainAddress:
                gainRamper.setUIValue(clamp(value, (float)-100.0, (float)100.0));
                break;

        }
    }

    AUValue getParameter(AUParameterAddress address) {
        switch (address) {
            case centerFrequencyAddress:
                return centerFrequencyRamper.getUIValue();

            case bandwidthAddress:
                return bandwidthRamper.getUIValue();

            case gainAddress:
                return gainRamper.getUIValue();

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

            case gainAddress:
                gainRamper.startRamp(clamp(value, (float)-100.0, (float)100.0), duration);
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
            double gain = double(gainRamper.getAndStep());

            int frameOffset = int(frameIndex + bufferOffset);

            eqfil->freq = (float)centerFrequency;
            eqfil->bw = (float)bandwidth;
            eqfil->gain = (float)gain;

            if (!started) {
                outBufferListPtr->mBuffers[0] = inBufferListPtr->mBuffers[0];
                outBufferListPtr->mBuffers[1] = inBufferListPtr->mBuffers[1];
                return;
            }
            for (int channel = 0; channel < channels; ++channel) {
                float *in  = (float *)inBufferListPtr->mBuffers[channel].mData  + frameOffset;
                float *out = (float *)outBufferListPtr->mBuffers[channel].mData + frameOffset;

                sp_eqfil_compute(sp, eqfil, in, out);
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
    sp_eqfil *eqfil;

public:
    bool started = true;
    AKParameterRamper centerFrequencyRamper = 1000;
    AKParameterRamper bandwidthRamper = 100;
    AKParameterRamper gainRamper = 10;
};

#endif /* AKEqualizerFilterDSPKernel_hpp */
