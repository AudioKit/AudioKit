//
//  AKFlatFrequencyResponseReverbDSPKernel.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKFlatFrequencyResponseReverbDSPKernel_hpp
#define AKFlatFrequencyResponseReverbDSPKernel_hpp

#import "DSPKernel.hpp"
#import "ParameterRamper.hpp"

#import <AudioKit/AudioKit-Swift.h>

extern "C" {
#include "soundpipe.h"
}

enum {
    reverbDurationAddress = 0
};

class AKFlatFrequencyResponseReverbDSPKernel : public DSPKernel {
public:
    // MARK: Member Functions

    AKFlatFrequencyResponseReverbDSPKernel() {}

    void init(int channelCount, double inSampleRate) {
        channels = channelCount;

        sampleRate = float(inSampleRate);

        sp_create(&sp);
        sp->sr = sampleRate;
        sp->nchan = channels;
        sp_allpass_create(&allpass);
        sp_allpass_init(sp, allpass, internalLoopDuration);
        allpass->revtime = 0.5;

        reverbDurationRamper.init();
    }

    void start() {
        started = true;
    }

    void stop() {
        started = false;
    }

    void destroy() {
        sp_allpass_destroy(&allpass);
        sp_destroy(&sp);
    }

    void reset() {
        resetted = true;
        reverbDurationRamper.reset();
    }

    void setReverbDuration(float value) {
        reverbDuration = clamp(value, 0.0f, 10.0f);
        reverbDurationRamper.setImmediate(reverbDuration);
    }

    void setLoopDuration(float duration) {
        internalLoopDuration = duration;
    }

    void setParameter(AUParameterAddress address, AUValue value) {
        switch (address) {
            case reverbDurationAddress:
                reverbDurationRamper.setUIValue(clamp(value, 0.0f, 10.0f));
                break;

        }
    }

    AUValue getParameter(AUParameterAddress address) {
        switch (address) {
            case reverbDurationAddress:
                return reverbDurationRamper.getUIValue();

            default: return 0.0f;
        }
    }

    void startRamp(AUParameterAddress address, AUValue value, AUAudioFrameCount duration) override {
        switch (address) {
            case reverbDurationAddress:
                reverbDurationRamper.startRamp(clamp(value, 0.0f, 10.0f), duration);
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

            reverbDuration = reverbDurationRamper.getAndStep();
            allpass->revtime = (float)reverbDuration;

            for (int channel = 0; channel < channels; ++channel) {
                float *in  = (float *)inBufferListPtr->mBuffers[channel].mData  + frameOffset;
                float *out = (float *)outBufferListPtr->mBuffers[channel].mData + frameOffset;

                if (started) {
                    sp_allpass_compute(sp, allpass, in, out);
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
    sp_allpass *allpass;

    float reverbDuration = 0.5;
    float internalLoopDuration = 0.1;

public:
    bool started = true;
    bool resetted = false;
    ParameterRamper reverbDurationRamper = 0.5;
};

#endif /* AKFlatFrequencyResponseReverbDSPKernel_hpp */
