//
//  AKVariableDelayDSPKernel.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKVariableDelayDSPKernel_hpp
#define AKVariableDelayDSPKernel_hpp

#import "AKDSPKernel.hpp"
#import "AKParameterRamper.hpp"

#import <AudioKit/AudioKit-Swift.h>

extern "C" {
#include "soundpipe.h"
}

enum {
    timeAddress = 0,
};

class AKVariableDelayDSPKernel : public AKDSPKernel {
public:
    // MARK: Member Functions

    AKVariableDelayDSPKernel() {}

    void init(int channelCount, double inSampleRate) {
        channels = channelCount;

        sampleRate = float(inSampleRate);

        sp_create(&sp);
        sp->sr = sampleRate;
        sp->nchan = channels;
        sp_vdelay_create(&vdelay);
        sp_vdelay_init(sp, vdelay, 5.0);
        vdelay->del = 1;

        sp_vdelay_create(&vdelay1);
        sp_vdelay_init(sp, vdelay1, 5.0);
        vdelay1->del = 1;

    }


    void start() {
        started = true;
    }

    void stop() {
        started = false;
    }

    void destroy() {
        sp_vdelay_destroy(&vdelay);
        sp_vdelay_destroy(&vdelay1);
        sp_destroy(&sp);
    }

    void reset() {
    }

    void setTime(float del) {
        time = del;
        timeRamper.set(clamp(del, (float)0, (float)10));
    }

    void setParameter(AUParameterAddress address, AUValue value) {
        switch (address) {
            case timeAddress:
                timeRamper.set(clamp(value, (float)0, (float)10));
                break;


        }
    }

    AUValue getParameter(AUParameterAddress address) {
        switch (address) {
            case timeAddress:
                return timeRamper.goal();

            default: return 0.0f;
        }
    }

    void startRamp(AUParameterAddress address, AUValue value, AUAudioFrameCount duration) override {
        switch (address) {
            case timeAddress:
                timeRamper.startRamp(clamp(value, (float)0, (float)10), duration);
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
            int frameOffset = int(frameIndex + bufferOffset);

            vdelay->del = double(timeRamper.getStep());
            vdelay1->del = double(timeRamper.getStep());
            if (!started) {
                outBufferListPtr->mBuffers[0] = inBufferListPtr->mBuffers[0];
                outBufferListPtr->mBuffers[1] = inBufferListPtr->mBuffers[1];
                return;
            }
            for (int channel = 0; channel < channels; ++channel) {
                float *in  = (float *)inBufferListPtr->mBuffers[channel].mData  + frameOffset;
                float *out = (float *)outBufferListPtr->mBuffers[channel].mData + frameOffset;
                if (channel == 1) {
                    sp_vdelay_compute(sp, vdelay1, in, out);
                } else {
                    sp_vdelay_compute(sp, vdelay, in, out);
                }
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
    sp_vdelay *vdelay;
    sp_vdelay *vdelay1;


    float time = 1;

public:
    bool started = true;
    AKParameterRamper timeRamper = 1;
};

#endif /* AKVariableDelayDSPKernel_hpp */
