//
//  AKTanhDistortionDSPKernel.hpp
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
    pregainAddress = 0,
    postgainAddress = 1,
    postiveShapeParameterAddress = 2,
    negativeShapeParameterAddress = 3
};

class AKTanhDistortionDSPKernel : public AKDSPKernel, public AKBuffered {
public:
    // MARK: Member Functions

    AKTanhDistortionDSPKernel() {}

    void init(int channelCount, double inSampleRate) {
        channels = channelCount;

        sampleRate = float(inSampleRate);

        sp_create(&sp);
        sp->sr = sampleRate;
        sp->nchan = channels;
        sp_dist_create(&dist);
        sp_dist_init(sp, dist);
        dist->pregain = 2.0;
        dist->postgain = 0.5;
        dist->shape1 = 0.0;
        dist->shape2 = 0.0;

        pregainRamper.init();
        postgainRamper.init();
        postiveShapeParameterRamper.init();
        negativeShapeParameterRamper.init();
    }

    void start() {
        started = true;
    }

    void stop() {
        started = false;
    }

    void destroy() {
        sp_dist_destroy(&dist);
        sp_destroy(&sp);
    }

    void reset() {
        resetted = true;
        pregainRamper.reset();
        postgainRamper.reset();
        postiveShapeParameterRamper.reset();
        negativeShapeParameterRamper.reset();
    }

    void setPregain(float value) {
        pregain = clamp(value, 0.0f, 10.0f);
        pregainRamper.setImmediate(pregain);
    }

    void setPostgain(float value) {
        postgain = clamp(value, 0.0f, 10.0f);
        postgainRamper.setImmediate(postgain);
    }

    void setPostiveShapeParameter(float value) {
        postiveShapeParameter = clamp(value, -10.0f, 10.0f);
        postiveShapeParameterRamper.setImmediate(postiveShapeParameter);
    }

    void setNegativeShapeParameter(float value) {
        negativeShapeParameter = clamp(value, -10.0f, 10.0f);
        negativeShapeParameterRamper.setImmediate(negativeShapeParameter);
    }


    void setParameter(AUParameterAddress address, AUValue value) {
        switch (address) {
            case pregainAddress:
                pregainRamper.setUIValue(clamp(value, 0.0f, 10.0f));
                break;

            case postgainAddress:
                postgainRamper.setUIValue(clamp(value, 0.0f, 10.0f));
                break;

            case postiveShapeParameterAddress:
                postiveShapeParameterRamper.setUIValue(clamp(value, -10.0f, 10.0f));
                break;

            case negativeShapeParameterAddress:
                negativeShapeParameterRamper.setUIValue(clamp(value, -10.0f, 10.0f));
                break;

        }
    }

    AUValue getParameter(AUParameterAddress address) {
        switch (address) {
            case pregainAddress:
                return pregainRamper.getUIValue();

            case postgainAddress:
                return postgainRamper.getUIValue();

            case postiveShapeParameterAddress:
                return postiveShapeParameterRamper.getUIValue();

            case negativeShapeParameterAddress:
                return negativeShapeParameterRamper.getUIValue();

            default: return 0.0f;
        }
    }

    void startRamp(AUParameterAddress address, AUValue value, AUAudioFrameCount duration) override {
        switch (address) {
            case pregainAddress:
                pregainRamper.startRamp(clamp(value, 0.0f, 10.0f), duration);
                break;

            case postgainAddress:
                postgainRamper.startRamp(clamp(value, 0.0f, 10.0f), duration);
                break;

            case postiveShapeParameterAddress:
                postiveShapeParameterRamper.startRamp(clamp(value, -10.0f, 10.0f), duration);
                break;

            case negativeShapeParameterAddress:
                negativeShapeParameterRamper.startRamp(clamp(value, -10.0f, 10.0f), duration);
                break;

        }
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {

        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {

            int frameOffset = int(frameIndex + bufferOffset);

            pregain = pregainRamper.getAndStep();
            dist->pregain = (float)pregain;
            postgain = postgainRamper.getAndStep();
            dist->postgain = (float)postgain;
            postiveShapeParameter = postiveShapeParameterRamper.getAndStep();
            dist->shape1 = (float)postiveShapeParameter;
            negativeShapeParameter = negativeShapeParameterRamper.getAndStep();
            dist->shape2 = (float)negativeShapeParameter;

            for (int channel = 0; channel < channels; ++channel) {
                float *in  = (float *)inBufferListPtr->mBuffers[channel].mData  + frameOffset;
                float *out = (float *)outBufferListPtr->mBuffers[channel].mData + frameOffset;

                if (started) {
                    sp_dist_compute(sp, dist, in, out);
                } else {
                    *out = *in;
                }
            }
        }
    }

    // MARK: Member Variables

private:

    sp_data *sp;
    sp_dist *dist;

    float pregain = 2.0;
    float postgain = 0.5;
    float postiveShapeParameter = 0.0;
    float negativeShapeParameter = 0.0;

public:
    bool started = true;
    bool resetted = false;
    ParameterRamper pregainRamper = 2.0;
    ParameterRamper postgainRamper = 0.5;
    ParameterRamper postiveShapeParameterRamper = 0.0;
    ParameterRamper negativeShapeParameterRamper = 0.0;
};


