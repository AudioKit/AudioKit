//
//  AKAmplitudeTrackerDSPKernel.hpp
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
    halfPowerPointAddress = 0
};

class AKAmplitudeTrackerDSPKernel : public AKDSPKernel, public AKBuffered {
public:
    // MARK: Member Functions

    AKAmplitudeTrackerDSPKernel() {}

    void init(int channelCount, double inSampleRate) {
        AKDSPKernel::init(channelCount, inSampleRate);

        sp_create(&sp);
        sp->sr = sampleRate;
        sp->nchan = channels;
        sp_rms_create(&rms);
        sp_rms_init(sp, rms);
        rms->ihp = 10;
    }

    void start() {
        started = true;
    }

    void stop() {
        started = false;
    }

    void destroy() {
        sp_rms_destroy(&rms);
        sp_destroy(&sp);
    }

    void reset() {
    }

    void setParameter(AUParameterAddress address, AUValue value) {
        switch (address) {
            case halfPowerPointAddress:
                halfPowerPointRamper.setUIValue(clamp(value, (float)0, (float)20000));
                break;

        }
    }

    AUValue getParameter(AUParameterAddress address) {
        switch (address) {
            case halfPowerPointAddress:
                return halfPowerPointRamper.getUIValue();

            default: return 0.0f;
        }
    }

    void startRamp(AUParameterAddress address, AUValue value, AUAudioFrameCount duration) override {
        switch (address) {
            case halfPowerPointAddress:
                halfPowerPointRamper.startRamp(clamp(value, (float)0, (float)20000), duration);
                break;

        }
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {

        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            double halfPowerPoint = double(halfPowerPointRamper.getAndStep());

            int frameOffset = int(frameIndex + bufferOffset);

            rms->ihp = (float)halfPowerPoint;

            for (int channel = 0; channel < channels; ++channel) {
                float *in  = (float *)inBufferListPtr->mBuffers[channel].mData  + frameOffset;
                float temp = *in;
                float *out = (float *)outBufferListPtr->mBuffers[channel].mData + frameOffset;
                if (started) {
                    sp_rms_compute(sp, rms, in, out);
                    trackedAmplitude = *out;
                } else {
                    trackedAmplitude = 0;
                }
                *out = temp;
            }
        }
    }

    // MARK: Member Variables

private:

    sp_data *sp;
    sp_rms *rms;

public:
    ParameterRamper halfPowerPointRamper = 10;
    bool started = true;
    float trackedAmplitude = 0.0;
};
