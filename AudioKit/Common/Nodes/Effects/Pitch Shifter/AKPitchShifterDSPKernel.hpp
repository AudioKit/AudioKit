//
//  AKPitchShifterDSPKernel.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKPitchShifterDSPKernel_hpp
#define AKPitchShifterDSPKernel_hpp

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
        *pshift->window = 1024.0;
        *pshift->xfade = 512.0;
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
    }

    void setShift(float shift) {
        shift = shift;
        shiftRamper.setImmediate(shift);
    }

    void setWindowSize(float window) {
        windowSize = window;
        windowSizeRamper.setImmediate(window);
    }

    void setCrossfade(float xfade) {
        crossfade = xfade;
        crossfadeRamper.setImmediate(xfade);
    }


    void setParameter(AUParameterAddress address, AUValue value) {
        switch (address) {
            case shiftAddress:
                shiftRamper.setUIValue(clamp(value, (float)-2400.0, (float)2400.0));
                break;

            case windowSizeAddress:
                windowSizeRamper.setUIValue(clamp(value, (float)0.0, (float)10000.0));
                break;

            case crossfadeAddress:
                crossfadeRamper.setUIValue(clamp(value, (float)0.0, (float)10000.0));
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
                shiftRamper.startRamp(clamp(value, (float)-2400.0, (float)2400.0), duration);
                break;

            case windowSizeAddress:
                windowSizeRamper.startRamp(clamp(value, (float)0.0, (float)10000.0), duration);
                break;

            case crossfadeAddress:
                crossfadeRamper.startRamp(clamp(value, (float)0.0, (float)10000.0), duration);
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

            shift = shiftRamper.getAndStep();
            *pshift->shift = (float)shift / 100.0; // Dividing to get semitones
            windowSize = windowSizeRamper.getAndStep();
            *pshift->window = (float)windowSize;
            crossfade = crossfadeRamper.getAndStep();
            *pshift->xfade = (float)crossfade;

            if (!started) {
                outBufferListPtr->mBuffers[0] = inBufferListPtr->mBuffers[0];
                outBufferListPtr->mBuffers[1] = inBufferListPtr->mBuffers[1];
                return;
            }
            for (int channel = 0; channel < channels; ++channel) {
                float *in  = (float *)inBufferListPtr->mBuffers[channel].mData  + frameOffset;
                float *out = (float *)outBufferListPtr->mBuffers[channel].mData + frameOffset;

                sp_pshift_compute(sp, pshift, in, out);
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
    float windowSize = 1000.0;
    float crossfade = 10.0;

public:
    bool started = true;
    bool resetted = false;
    ParameterRamper shiftRamper = 0;
    ParameterRamper windowSizeRamper = 1000.0;
    ParameterRamper crossfadeRamper = 10.0;
};

#endif /* AKPitchShifterDSPKernel_hpp */
