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

        globalSampleRate = float(inSampleRate);

        sp_create(&sp);
        sp->sr = globalSampleRate;
        sp->nchan = channels;
        sp_bitcrush_create(&bitcrush);
        sp_bitcrush_init(sp, bitcrush);
        bitcrush->bitdepth = 8;
        bitcrush->srate = 10000;

        bitDepthRamper.init();
        sampleRateRamper.init();
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
        resetted = true;
        bitDepthRamper.reset();
        sampleRateRamper.reset();
    }

    void setBitDepth(float value) {
        bitDepth = clamp(value, 1.0f, 24.0f);
        bitDepthRamper.setImmediate(bitDepth);
    }

    void setSampleRate(float value) {
        sampleRate = clamp(value, 1.0f, 20000.0f);
        sampleRateRamper.setImmediate(sampleRate);
    }


    void setParameter(AUParameterAddress address, AUValue value) {
        switch (address) {
            case bitDepthAddress:
                bitDepthRamper.setUIValue(clamp(value, 1.f, 24.f));
                break;

            case sampleRateAddress:
                sampleRateRamper.setUIValue(clamp(value, 1.0f, 20000.0f));
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
                bitDepthRamper.startRamp(clamp(value, 1.f, 24.f), duration);
                break;

            case sampleRateAddress:
                sampleRateRamper.startRamp(clamp(value, 1.0f, 20000.0f), duration);
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

            bitDepth = bitDepthRamper.getAndStep();
            bitcrush->bitdepth = (float)bitDepth;
            sampleRate = sampleRateRamper.getAndStep();
            bitcrush->srate = (float)sampleRate;

            for (int channel = 0; channel < channels; ++channel) {
                float *in  = (float *)inBufferListPtr->mBuffers[channel].mData  + frameOffset;
                float *out = (float *)outBufferListPtr->mBuffers[channel].mData + frameOffset;

                if (started) {
                    sp_bitcrush_compute(sp, bitcrush, in, out);
                } else {
                    *out = *in;
                }
            }
        }
    }

    // MARK: Member Variables

private:
    int channels = AKSettings.numberOfChannels;
    float globalSampleRate = AKSettings.sampleRate;

    AudioBufferList *inBufferListPtr = nullptr;
    AudioBufferList *outBufferListPtr = nullptr;

    sp_data *sp;
    sp_bitcrush *bitcrush;

    float bitDepth = 8;
    float sampleRate = 10000;

public:
    bool started = true;
    bool resetted = false;
    ParameterRamper bitDepthRamper = 8;
    ParameterRamper sampleRateRamper = 10000;
};

#endif /* AKBitCrusherDSPKernel_hpp */
