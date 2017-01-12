//
//  AKTesterDSPKernel.hpp
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
#include "md5.h"
#include "test.h"
}


class AKTesterDSPKernel : public AKDSPKernel, AKBuffered {
public:
    // MARK: Member Functions

    AKTesterDSPKernel() {}

    void init(int channelCount, double inSampleRate) {
        channels = channelCount;

        sp_create(&sp);
        sampleRate = float(inSampleRate);
        sp_srand(sp, 12345);
    }

    void setSamples(UInt32 numberOfSamples)  {
        totalSamples = numberOfSamples;
        sp_test_create(&sp_test, numberOfSamples);
    }
    
    NSString *getMD5() {
        md5 = [@"" cStringUsingEncoding:NSUTF8StringEncoding];
        sp_test_compare(sp_test, md5);
        return [NSString stringWithCString:sp_test->md5 encoding:NSUTF8StringEncoding];
    }
    int getSamples() {
        return samples;
    }
    
    void start() {
        started = true;
    }
    
    void stop() {
        started = false;
    }
    
    void destroy() {
        sp_test_destroy(&sp_test);
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
        // For each sample.

        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {

            int frameOffset = int(frameIndex + bufferOffset);
            
            for (int channel = 0; channel < channels; ++channel) {
                float *in  = (float *)inBufferListPtr->mBuffers[channel].mData  + frameOffset;
                float *out = (float *)outBufferListPtr->mBuffers[channel].mData + frameOffset;
                if (started && samples < totalSamples) {
                    sp_test_add_sample(sp_test, (SPFLOAT)*in);
                    samples++;
                }
                // Suppress output
                *out = 0;
            }
        }
    }

    // MARK: Member Variables

private:

    sp_data *sp = nil;
    sp_test *sp_test = nil;
    UInt32 samples = 0;
    UInt32 totalSamples = 0;
    const char *md5;
    
public:
    bool started = true;
};


