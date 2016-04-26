//
//  AKTanhDistortionDSPKernel.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKTanhDistortionDSPKernel_hpp
#define AKTanhDistortionDSPKernel_hpp

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

class AKTanhDistortionDSPKernel : public DSPKernel {
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
    }

    void setParameter(AUParameterAddress address, AUValue value) {
        switch (address) {
            case pregainAddress:
                pregainRamper.setUIValue(clamp(value, (float)0.0, (float)10.0));
                break;

            case postgainAddress:
                postgainRamper.setUIValue(clamp(value, (float)0.0, (float)10.0));
                break;

            case postiveShapeParameterAddress:
                postiveShapeParameterRamper.setUIValue(clamp(value, (float)-10.0, (float)10.0));
                break;

            case negativeShapeParameterAddress:
                negativeShapeParameterRamper.setUIValue(clamp(value, (float)-10.0, (float)10.0));
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
                pregainRamper.startRamp(clamp(value, (float)0.0, (float)10.0), duration);
                break;

            case postgainAddress:
                postgainRamper.startRamp(clamp(value, (float)0.0, (float)10.0), duration);
                break;

            case postiveShapeParameterAddress:
                postiveShapeParameterRamper.startRamp(clamp(value, (float)-10.0, (float)10.0), duration);
                break;

            case negativeShapeParameterAddress:
                negativeShapeParameterRamper.startRamp(clamp(value, (float)-10.0, (float)10.0), duration);
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
            double pregain = double(pregainRamper.getAndStep());
            double postgain = double(postgainRamper.getAndStep());
            double postiveShapeParameter = double(postiveShapeParameterRamper.getAndStep());
            double negativeShapeParameter = double(negativeShapeParameterRamper.getAndStep());

            int frameOffset = int(frameIndex + bufferOffset);

            dist->pregain = (float)pregain;
            dist->postgain = (float)postgain;
            dist->shape1 = (float)postiveShapeParameter;
            dist->shape2 = (float)negativeShapeParameter;

            if (!started) {
                outBufferListPtr->mBuffers[0] = inBufferListPtr->mBuffers[0];
                outBufferListPtr->mBuffers[1] = inBufferListPtr->mBuffers[1];
                return;
            }
            for (int channel = 0; channel < channels; ++channel) {
                float *in  = (float *)inBufferListPtr->mBuffers[channel].mData  + frameOffset;
                float *out = (float *)outBufferListPtr->mBuffers[channel].mData + frameOffset;

                sp_dist_compute(sp, dist, in, out);
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
    sp_dist *dist;

public:
    bool started = true;
    ParameterRamper pregainRamper = 2.0;
    ParameterRamper postgainRamper = 0.5;
    ParameterRamper postiveShapeParameterRamper = 0.0;
    ParameterRamper negativeShapeParameterRamper = 0.0;
};

#endif /* AKTanhDistortionDSPKernel_hpp */
