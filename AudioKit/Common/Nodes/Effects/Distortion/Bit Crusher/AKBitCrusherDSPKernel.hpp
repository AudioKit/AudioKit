//
//  AKBitCrusherDSPKernel.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2017 Aurelius Prochazka. All rights reserved.
//

#pragma once

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

class AKBitCrusherDSPKernel : public AKSoundpipeKernel, public AKBuffered {
public:
    // MARK: Member Functions

    AKBitCrusherDSPKernel() {}

    void init(int _channels, double _sampleRate) override {
        AKSoundpipeKernel::init(_channels, _sampleRate);

        sp_bitcrush_create(&bitcrush0);
        sp_bitcrush_create(&bitcrush1);
        sp_bitcrush_init(sp, bitcrush0);
        sp_bitcrush_init(sp, bitcrush1);
        bitcrush0->bitdepth = 8;
        bitcrush1->bitdepth = 8;
        bitcrush0->srate = 10000;
        bitcrush1->srate = 10000;

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
        sp_bitcrush_destroy(&bitcrush0);
        sp_bitcrush_destroy(&bitcrush1);
        AKSoundpipeKernel::destroy();
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

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {

        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {

            int frameOffset = int(frameIndex + bufferOffset);

            bitDepth = bitDepthRamper.getAndStep();
            bitcrush0->bitdepth = (float)bitDepth;
            bitcrush1->bitdepth = (float)bitDepth;
            sampleRate = sampleRateRamper.getAndStep();
            bitcrush0->srate = (float)sampleRate;
            bitcrush1->srate = (float)sampleRate;

            for (int channel = 0; channel < channels; ++channel) {
                float *in  = (float *)inBufferListPtr->mBuffers[channel].mData  + frameOffset;
                float *out = (float *)outBufferListPtr->mBuffers[channel].mData + frameOffset;

                if (started) {
                    if (channel == 0) {
                        sp_bitcrush_compute(sp, bitcrush0, in, out);
                    } else {
                        sp_bitcrush_compute(sp, bitcrush1, in, out);
                    }
                } else {
                    *out = *in;
                }
            }
        }
    }

    // MARK: Member Variables

private:

    sp_bitcrush *bitcrush0;
    sp_bitcrush *bitcrush1;

    float bitDepth = 8;
    float sampleRate = 10000;

public:
    bool started = true;
    bool resetted = false;
    ParameterRamper bitDepthRamper = 8;
    ParameterRamper sampleRateRamper = 10000;
};
