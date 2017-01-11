//
//  AKConvolutionDSPKernel.hpp
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


class AKConvolutionDSPKernel : public AKDSPKernel {
public:
    // MARK: Member Functions

    AKConvolutionDSPKernel() {}

    void init(int channelCount, double inSampleRate) {
        channels = channelCount;

        sampleRate = float(inSampleRate);

        sp_create(&sp);
        sp->sr = sampleRate;
        sp->nchan = channels;
        sp_conv_create(&conv);

    }

    void setPartitionLength(int partLength) {
        partitionLength = partLength;
    }

    void start() {
        started = true;
        sp_conv_init(sp, conv, ftbl, (float)partitionLength);
    }

    void stop() {
        started = false;
    }
    
    void setUpTable(float *table, UInt32 size) {
        ftbl_size = size;
        sp_ftbl_create(sp, &ftbl, ftbl_size);
        ftbl->tbl = table;
    }

    void destroy() {
        sp_conv_destroy(&conv);
        sp_destroy(&sp);
    }

    void reset() {
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

    void setBuffers(AudioBufferList *inBufferList, AudioBufferList *outBufferList) {
        inBufferListPtr = inBufferList;
        outBufferListPtr = outBufferList;
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {

        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            int frameOffset = int(frameIndex + bufferOffset);

            for (int channel = 0; channel < channels; ++channel) {
                float *in  = (float *)inBufferListPtr->mBuffers[channel].mData  + frameOffset;
                float *out = (float *)outBufferListPtr->mBuffers[channel].mData + frameOffset;
                
                if (started) {
                    sp_conv_compute(sp, conv, in, out);
                    *out = *out * 0.05; // Hack
                } else {
                    *out = *in;
                }
            }
        }
    }

    // MARK: Member Variables

private:

    int partitionLength = 2048;

    AudioBufferList *inBufferListPtr = nullptr;
    AudioBufferList *outBufferListPtr = nullptr;

    sp_data *sp;
    sp_conv *conv;
    sp_ftbl *ftbl;
    UInt32 ftbl_size = 4096;

public:
    bool started = true;
    bool resetted = true;
};

