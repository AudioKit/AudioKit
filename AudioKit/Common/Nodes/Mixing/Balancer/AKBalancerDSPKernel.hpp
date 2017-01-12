//
//  AKBalancerDSPKernel.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#pragma once

#import "DSPKernel.hpp"
#import "ParameterRamper.hpp"

#import <AudioKit/AudioKit-Swift.h>

extern "C" {
#include "soundpipe.h"
}


class AKBalancerDSPKernel : public AKDSPKernel, public AKBuffered {
public:
    // MARK: Member Functions

    AKBalancerDSPKernel() {}

    void init(int channelCount, double inSampleRate) {
        AKDSPKernel::init(channelCount, inSampleRate);

        sp_create(&sp);
        sp->sr = sampleRate;
        sp->nchan = channels;
        sp_bal_create(&bal);
        sp_bal_init(sp, bal);
    }

    void start() {
        started = true;
    }
    
    void stop() {
        started = false;
    }
    
    void destroy() {
        sp_bal_destroy(&bal);
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

    void setBuffers(AudioBufferList* inBufferList, AudioBufferList *compBufferList, AudioBufferList* outBufferList) {
        
        inBufferListPtr = inBufferList;
        compBufferListPtr = compBufferList;
        outBufferListPtr = outBufferList;
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {
        
        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {

            int frameOffset = int(frameIndex + bufferOffset);

            for (int channel = 0; channel < channels; ++channel) {
                float *in   = (float *)inBufferListPtr->mBuffers[channel].mData  + frameOffset;
                float *comp = (float *)compBufferListPtr->mBuffers[channel].mData + frameOffset;
                float *out  = (float *)outBufferListPtr->mBuffers[channel].mData + frameOffset;
                
                if (started) {
                    sp_bal_compute(sp, bal, in, comp, out);
                } else {
                    *out = *in;
                }
            }
        }
    }

    // MARK: Member Variables

private:

    int inputChannels = 4;

    AudioBufferList *compBufferListPtr = nullptr;

    sp_data *sp;
    sp_bal *bal;

public:
    bool started = true;
};

