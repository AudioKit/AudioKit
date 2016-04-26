//
//  AKFrequencyTrackerDSPKernel.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#ifndef AKFrequencyTrackerDSPKernel_hpp
#define AKFrequencyTrackerDSPKernel_hpp

#import "DSPKernel.hpp"
#import "ParameterRamper.hpp"

#import <AudioKit/AudioKit-Swift.h>

extern "C" {
#include "soundpipe.h"
}


class AKFrequencyTrackerDSPKernel : public DSPKernel {
public:
    // MARK: Member Functions

    AKFrequencyTrackerDSPKernel() {}

    void init(int channelCount, double inSampleRate) {
        channels = channelCount;

        sampleRate = float(inSampleRate);

        sp_create(&sp);
        sp->sr = sampleRate;
        sp->nchan = channels;
        sp_pitchamdf_create(&pitchamdf);
        sp_pitchamdf_init(sp, pitchamdf, minimumFrequency, maximumFrequency);
    }
    
    void start() {
        started = true;
    }
    
    void stop() {
        started = false;
    }

    void destroy() {
        sp_pitchamdf_destroy(&pitchamdf);
        sp_destroy(&sp);
    }
    
    void reset() {
    }
    
    void setFrequencyLimits(float min, float max) {
        minimumFrequency = min;
        maximumFrequency = max;
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
                float temp = *in;
                float *out = (float *)outBufferListPtr->mBuffers[channel].mData + frameOffset;
                if (started) {
                    sp_pitchamdf_compute(sp, pitchamdf, in, &trackedFrequency, &trackedAmplitude);
                } else {
                    trackedAmplitude = 0;
                    trackedFrequency = 0;
                }
                *out = temp;
            }
        }
    }

    // MARK: Member Variables

private:

    int channels = AKSettings.numberOfChannels;
    float sampleRate = AKSettings.sampleRate;
    
    float minimumFrequency = 20;
    float maximumFrequency = 4000;

    AudioBufferList* inBufferListPtr = nullptr;
    AudioBufferList* outBufferListPtr = nullptr;

    sp_data *sp;
    sp_pitchamdf *pitchamdf;
    
public:
    float trackedAmplitude = 0.0;
    float trackedFrequency = 0.0;
    bool started = true;
};

#endif /* AKFrequencyTrackerDSPKernel_hpp */
