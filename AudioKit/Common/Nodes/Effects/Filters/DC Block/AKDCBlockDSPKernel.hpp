//
//  AKDCBlockDSPKernel.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

#pragma once

#import "DSPKernel.hpp"
#import "ParameterRamper.hpp"

#import <AudioKit/AudioKit-Swift.h>

extern "C" {
#include "soundpipe.h"
}


class AKDCBlockDSPKernel : public AKSoundpipeKernel, public AKBuffered {
public:
    // MARK: Member Functions

    AKDCBlockDSPKernel() {}

    void init(int _channels, double _sampleRate) override {
        AKSoundpipeKernel::init(_channels, _sampleRate);

        sp_dcblock_create(&dcblock0);
        sp_dcblock_create(&dcblock1);
        sp_dcblock_init(sp, dcblock0);
        sp_dcblock_init(sp, dcblock1);

    }

    void start() {
        started = true;
    }

    void stop() {
        started = false;
    }

    void destroy() {
        sp_dcblock_destroy(&dcblock0);
        sp_dcblock_destroy(&dcblock1);
        AKSoundpipeKernel::destroy();
    }

    void reset() {
        resetted = true;
    }


    void setParameter(AUParameterAddress address, AUValue value) {
        switch (address) {
        }
    }

    AUValue getParameter(AUParameterAddress address) {
        switch (address) {
            default: return 0.0f;
        }
    }

    void startRamp(AUParameterAddress address, AUValue value, AUAudioFrameCount duration) override {
        switch (address) {
        }
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {

        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {

            int frameOffset = int(frameIndex + bufferOffset);


            for (int channel = 0; channel < channels; ++channel) {
                float *in  = (float *)inBufferListPtr->mBuffers[channel].mData  + frameOffset;
                float *out = (float *)outBufferListPtr->mBuffers[channel].mData + frameOffset;

                if (started) {
                    if (channel == 0) {
                        sp_dcblock_compute(sp, dcblock0, in, out);
                    } else {
                        sp_dcblock_compute(sp, dcblock1, in, out);
                    }
                } else {
                    *out = *in;
                }
            }
        }
    }

    // MARK: Member Variables

private:

    sp_dcblock *dcblock0;
    sp_dcblock *dcblock1;


public:
    bool started = true;
    bool resetted = false;
};
