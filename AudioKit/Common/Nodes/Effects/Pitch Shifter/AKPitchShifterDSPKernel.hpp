//
//  AKPitchShifterDSPKernel.hpp
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
    shiftAddress = 0,
    windowSizeAddress = 1,
    crossfadeAddress = 2
};

class AKPitchShifterDSPKernel : public DSPKernel {
public:
    // MARK: Member Functions

    AKPitchShifterDSPKernel() {}

    void init(int channelCount, double inSampleRate) {
        channels = channelCount;

        sampleRate = float(inSampleRate);

        sp_create(&sp);
        sp->sr = sampleRate;
        sp->nchan = channels;
        sp_pshift_create(&pshift);
        sp_pshift_init(sp, pshift);
        *pshift->shift = 0;
        *pshift->window = 1024;
        *pshift->xfade = 512;

        shiftRamper.init();
        windowSizeRamper.init();
        crossfadeRamper.init();
    }

    void start() {
        started = true;
    }

    void stop() {
        started = false;
    }

    void destroy() {
        sp_pshift_destroy(&pshift);
        sp_destroy(&sp);
    }

    void reset() {
        resetted = true;
        shiftRamper.reset();
        windowSizeRamper.reset();
        crossfadeRamper.reset();
    }

    void setShift(float value) {
        shift = clamp(value, -24.0f, 24.0f);
        shiftRamper.setImmediate(shift);
    }

    void setWindowSize(float value) {
        windowSize = clamp(value, 0.0f, 10000.0f);
        windowSizeRamper.setImmediate(windowSize);
    }

    void setCrossfade(float value) {
        crossfade = clamp(value, 0.0f, 10000.0f);
        crossfadeRamper.setImmediate(crossfade);
    }


    void setParameter(AUParameterAddress address, AUValue value) {
        switch (address) {
            case shiftAddress:
                shiftRamper.setUIValue(clamp(value, -24.0f, 24.0f));
                break;

            case windowSizeAddress:
                windowSizeRamper.setUIValue(clamp(value, 0.0f, 10000.0f));
                break;

            case crossfadeAddress:
                crossfadeRamper.setUIValue(clamp(value, 0.0f, 10000.0f));
                break;

        }
    }

    AUValue getParameter(AUParameterAddress address) {
        switch (address) {
            case shiftAddress:
                return shiftRamper.getUIValue();

            case windowSizeAddress:
                return windowSizeRamper.getUIValue();

            case crossfadeAddress:
                return crossfadeRamper.getUIValue();

            default: return 0.0f;
        }
    }

    void startRamp(AUParameterAddress address, AUValue value, AUAudioFrameCount duration) override {
        switch (address) {
            case shiftAddress:
                shiftRamper.startRamp(clamp(value, -24.0f, 24.0f), duration);
                break;

            case windowSizeAddress:
                windowSizeRamper.startRamp(clamp(value, 0.0f, 10000.0f), duration);
                break;

            case crossfadeAddress:
                crossfadeRamper.startRamp(clamp(value, 0.0f, 10000.0f), duration);
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

            shift = shiftRamper.getAndStep();
            *pshift->shift = (float)shift;
            windowSize = windowSizeRamper.getAndStep();
            *pshift->window = (float)windowSize;
            crossfade = crossfadeRamper.getAndStep();
            *pshift->xfade = (float)crossfade;

            for (int channel = 0; channel < channels; ++channel) {
                float *in  = (float *)inBufferListPtr->mBuffers[channel].mData  + frameOffset;
                float *out = (float *)outBufferListPtr->mBuffers[channel].mData + frameOffset;

                if (started) {
                    sp_pshift_compute(sp, pshift, in, out);
                } else {
                    *out = *in;
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
    sp_pshift *pshift;

    float shift = 0;
    float windowSize = 1024;
    float crossfade = 512;

public:
    bool started = true;
    bool resetted = false;
    ParameterRamper shiftRamper = 0;
    ParameterRamper windowSizeRamper = 1024;
    ParameterRamper crossfadeRamper = 512;
};

