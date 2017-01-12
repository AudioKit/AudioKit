//
//  AKPannerDSPKernel.hpp
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

enum {
    panAddress = 0
};

class AKPannerDSPKernel : public AKDSPKernel {
public:
    // MARK: Member Functions

    AKPannerDSPKernel() {}

    void init(int channelCount, double inSampleRate) {
        channels = channelCount;

        sampleRate = float(inSampleRate);

        sp_create(&sp);
        sp->sr = sampleRate;
        sp->nchan = channels;
        sp_panst_create(&panst);
        sp_panst_init(sp, panst);
        panst->pan = 0;

        panRamper.init();
    }

    void start() {
        started = true;
    }

    void stop() {
        started = false;
    }

    void destroy() {
        sp_panst_destroy(&panst);
        sp_destroy(&sp);
    }

    void reset() {
        resetted = true;
        panRamper.reset();
    }

    void setPan(float value) {
        pan = clamp(value, -1.0f, 1.0f);
        panRamper.setImmediate(pan);
    }


    void setParameter(AUParameterAddress address, AUValue value) {
        switch (address) {
            case panAddress:
                panRamper.setUIValue(clamp(value, -1.0f, 1.0f));
                break;

        }
    }

    AUValue getParameter(AUParameterAddress address) {
        switch (address) {
            case panAddress:
                return panRamper.getUIValue();

            default: return 0.0f;
        }
    }

    void startRamp(AUParameterAddress address, AUValue value, AUAudioFrameCount duration) override {
        switch (address) {
            case panAddress:
                panRamper.startRamp(clamp(value, -1.0f, 1.0f), duration);
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

            pan = panRamper.getAndStep();
            panst->pan = (float)pan;

            if (!started) {
                outBufferListPtr->mBuffers[0] = inBufferListPtr->mBuffers[0];
                outBufferListPtr->mBuffers[1] = inBufferListPtr->mBuffers[1];
                return;
            }
            
            float *tmpin[2];
            float *tmpout[2];
            for (int channel = 0; channel < channels; ++channel) {
                float *in  = (float *)inBufferListPtr->mBuffers[channel].mData  + frameOffset;
                float *out = (float *)outBufferListPtr->mBuffers[channel].mData + frameOffset;
                if (channel < 2) {
                    tmpin[channel] = in;
                    tmpout[channel] = out;
                }
            }
            sp_panst_compute(sp, panst, tmpin[0], tmpin[1], tmpout[0], tmpout[1]);
            
        }
    }

    // MARK: Member Variables

private:

    AudioBufferList *inBufferListPtr = nullptr;
    AudioBufferList *outBufferListPtr = nullptr;

    sp_data *sp;
    sp_panst *panst;
    
    float pan = 0.0;

public:
    bool started = true;
    bool resetted = false;
    ParameterRamper panRamper = 0;
};

