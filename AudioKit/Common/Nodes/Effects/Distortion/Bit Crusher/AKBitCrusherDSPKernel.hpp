//
//  AKBitCrusherDSPKernel.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKBitCrusherDSPKernel_hpp
#define AKBitCrusherDSPKernel_hpp

#import "DSPKernel.hpp"
#import "ParameterRamper.hpp"

#import <AudioKit/AudioKit-Swift.h>

extern "C" {
#include "soundpipe.h"
}

enum {
    bitDepthAddress = 0,
    sampleRateAddress = 1
};

class AKBitCrusherDSPKernel : public DSPKernel {
public:
    // MARK: Member Functions

    AKBitCrusherDSPKernel() {}

    void init(int channelCount, double inSampleRate) {
        channels = channelCount;

        sampleRate = float(inSampleRate);

        sp_create(&sp);
        sp->sr = sampleRate;
        sp->nchan = channels;
        sp_bitcrush_create(&bitcrush);
        sp_bitcrush_init(sp, bitcrush);
        bitcrush->bitdepth = 8;
        bitcrush->srate = 10000;
    }

    void start() {
        started = true;
    }

    void stop() {
        started = false;
    }

    void destroy() {
        sp_bitcrush_destroy(&bitcrush);
        sp_destroy(&sp);
    }

    void reset() {
    }

    void setParameter(AUParameterAddress address, AUValue value) {
        switch (address) {
            case bitDepthAddress:
                bitDepthRamper.setUIValue(clamp(value, (float)1, (float)24));
                break;

            case sampleRateAddress:
                sampleRateRamper.setUIValue(clamp(value, (float)0.0, (float)20000.0));
                break;

        }
    }

    AUValue getParameter(AUParameterAddress address) {
        switch (address) {
            case bitDepthAddress:
                return bitDepthRamper.getUIValue();

            case sampleRateAddress:
                return sampleRateRamper.getUIValue();

            default: return 0.0f;
        }
    }

    void startRamp(AUParameterAddress address, AUValue value, AUAudioFrameCount duration) override {
        switch (address) {
            case bitDepthAddress:
                bitDepthRamper.startRamp(clamp(value, (float)1, (float)24), duration);
                break;

            case sampleRateAddress:
                sampleRateRamper.startRamp(clamp(value, (float)0.0, (float)20000.0), duration);
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
            double bitDepth = double(bitDepthRamper.getAndStep());
            double sampleRate = double(sampleRateRamper.getAndStep());

            int frameOffset = int(frameIndex + bufferOffset);

            bitcrush->bitdepth = (float)bitDepth;
            bitcrush->srate = (float)sampleRate;

            if (!started) {
                outBufferListPtr->mBuffers[0] = inBufferListPtr->mBuffers[0];
                outBufferListPtr->mBuffers[1] = inBufferListPtr->mBuffers[1];
                return;
            }
            for (int channel = 0; channel < channels; ++channel) {
                float *in  = (float *)inBufferListPtr->mBuffers[channel].mData  + frameOffset;
                float *out = (float *)outBufferListPtr->mBuffers[channel].mData + frameOffset;

                sp_bitcrush_compute(sp, bitcrush, in, out);
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
    sp_bitcrush *bitcrush;

public:
    bool started = true;
    ParameterRamper bitDepthRamper = 8;
    ParameterRamper sampleRateRamper = 10000;
};

#endif /* AKBitCrusherDSPKernel_hpp */
