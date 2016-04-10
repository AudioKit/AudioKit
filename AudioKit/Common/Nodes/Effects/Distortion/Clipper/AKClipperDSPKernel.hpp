//
//  AKClipperDSPKernel.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKClipperDSPKernel_hpp
#define AKClipperDSPKernel_hpp

#import "AKDSPKernel.hpp"
#import "AKParameterRamper.hpp"

#import <AudioKit/AudioKit-Swift.h>

extern "C" {
#include "soundpipe.h"
}

enum {
    limitAddress = 0,
    clippingStartPointAddress = 1,
    methodAddress = 2
};

class AKClipperDSPKernel : public AKDSPKernel {
public:
    // MARK: Member Functions

    AKClipperDSPKernel() {}

    void init(int channelCount, double inSampleRate) {
        channels = channelCount;

        sampleRate = float(inSampleRate);

        sp_create(&sp);
        sp->sr = sampleRate;
        sp->nchan = channels;
        sp_clip_create(&clip);

    }

    void start() {
        started = true;
    }

    void stop() {
        started = false;
    }

    void destroy() {
        sp_clip_destroy(&clip);
        sp_destroy(&sp);
    }

    void reset() {
        sp_clip_init(sp, clip);
        clip->lim = 1.0;
        clip->arg = 0.5;
        clip->meth = 0;
    }

    void setParameter(AUParameterAddress address, AUValue value) {
        switch (address) {
            case limitAddress:
                limitRamper.set(clamp(value, (float)0.0, (float)1.0));
                break;

            case clippingStartPointAddress:
                clippingStartPointRamper.set(clamp(value, (float)0.0, (float)1.0));
                break;

            case methodAddress:
                methodRamper.set(clamp(value, (float)0, (float)2));
                break;

        }
    }

    AUValue getParameter(AUParameterAddress address) {
        switch (address) {
            case limitAddress:
                return limitRamper.goal();

            case clippingStartPointAddress:
                return clippingStartPointRamper.goal();

            case methodAddress:
                return methodRamper.goal();

            default: return 0.0f;
        }
    }

    void startRamp(AUParameterAddress address, AUValue value, AUAudioFrameCount duration) override {
        switch (address) {
            case limitAddress:
                limitRamper.startRamp(clamp(value, (float)0.0, (float)1.0), duration);
                break;

            case clippingStartPointAddress:
                clippingStartPointRamper.startRamp(clamp(value, (float)0.0, (float)1.0), duration);
                break;

            case methodAddress:
                methodRamper.startRamp(clamp(value, (float)0, (float)2), duration);
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
            double limit = double(limitRamper.getStep());
            double clippingStartPoint = double(clippingStartPointRamper.getStep());
            double method = double(methodRamper.getStep());

            int frameOffset = int(frameIndex + bufferOffset);

            clip->lim = (float)limit;
            clip->arg = (float)clippingStartPoint;
            clip->meth = (int)method;

            if (!started) {
                outBufferListPtr->mBuffers[0] = inBufferListPtr->mBuffers[0];
                outBufferListPtr->mBuffers[1] = inBufferListPtr->mBuffers[1];
                return;
            }
            for (int channel = 0; channel < channels; ++channel) {
                float *in  = (float *)inBufferListPtr->mBuffers[channel].mData  + frameOffset;
                float *out = (float *)outBufferListPtr->mBuffers[channel].mData + frameOffset;
                sp_clip_compute(sp, clip, in, out);
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
    sp_clip *clip;

public:
    bool started = true;
    AKParameterRamper limitRamper = 1.0;
    AKParameterRamper clippingStartPointRamper = 0.5;
    AKParameterRamper methodRamper = 0;
};

#endif /* AKClipperDSPKernel_hpp */
