//
//  AKVocoderDSPKernel.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKVocoderDSPKernel_hpp
#define AKVocoderDSPKernel_hpp

#import "DSPKernel.hpp"
#import "ParameterRamper.hpp"

#import <AudioKit/AudioKit-Swift.h>

extern "C" {
#include "soundpipe.h"
}

enum {
    attackTimeAddress = 0,
    releaseTimeAddress = 1,
    bandwidthRatioAddress = 2
};

class AKVocoderDSPKernel : public DSPKernel {
public:
    // MARK: Member Functions

    AKVocoderDSPKernel() {}

    void init(int channelCount, double inSampleRate) {
        channels = channelCount;

        sampleRate = float(inSampleRate);

        sp_create(&sp);
        sp->sr = sampleRate;
        sp->nchan = channels;
        sp_vocoder_create(&vocoder);
        sp_vocoder_init(sp, vocoder);
        *vocoder->atk = 0.1;
        *vocoder->rel = 0.1;
        *vocoder->bwratio = 0.5;

        attackTimeRamper.init();
        releaseTimeRamper.init();
        bandwidthRatioRamper.init();
    }

    void start() {
        started = true;
    }

    void stop() {
        started = false;
    }

    void destroy() {
        sp_vocoder_destroy(&vocoder);
        sp_destroy(&sp);
    }

    void reset() {
        resetted = true;
        attackTimeRamper.reset();
        releaseTimeRamper.reset();
        bandwidthRatioRamper.reset();
    }

    void setAttackTime(float value) {
        attackTime = clamp(value, 0.001f, 0.5f);
        attackTimeRamper.setImmediate(attackTime);
    }

    void setReleaseTime(float value) {
        releaseTime = clamp(value, 0.001f, 0.5f);
        releaseTimeRamper.setImmediate(releaseTime);
    }

    void setBandwidthRatio(float value) {
        bandwidthRatio = clamp(value, 0.1f, 2.0f);
        bandwidthRatioRamper.setImmediate(bandwidthRatio);
    }


    void setParameter(AUParameterAddress address, AUValue value) {
        switch (address) {
            case attackTimeAddress:
                attackTimeRamper.setUIValue(clamp(value, 0.001f, 0.5f));
                break;

            case releaseTimeAddress:
                releaseTimeRamper.setUIValue(clamp(value, 0.001f, 0.5f));
                break;

            case bandwidthRatioAddress:
                bandwidthRatioRamper.setUIValue(clamp(value, 0.1f, 2.0f));
                break;

        }
    }

    AUValue getParameter(AUParameterAddress address) {
        switch (address) {
            case attackTimeAddress:
                return attackTimeRamper.getUIValue();

            case releaseTimeAddress:
                return releaseTimeRamper.getUIValue();

            case bandwidthRatioAddress:
                return bandwidthRatioRamper.getUIValue();

            default: return 0.0f;
        }
    }

    void startRamp(AUParameterAddress address, AUValue value, AUAudioFrameCount duration) override {
        switch (address) {
            case attackTimeAddress:
                attackTimeRamper.startRamp(clamp(value, 0.001f, 0.5f), duration);
                break;

            case releaseTimeAddress:
                releaseTimeRamper.startRamp(clamp(value, 0.001f, 0.5f), duration);
                break;

            case bandwidthRatioAddress:
                bandwidthRatioRamper.startRamp(clamp(value, 0.1f, 2.0f), duration);
                break;

        }
    }

    void setBuffers(AudioBufferList *inBufferList, AudioBufferList *exciteBufferList, AudioBufferList *outBufferList) {
        inBufferListPtr = inBufferList;
        exciteBufferListPtr = exciteBufferList;
        outBufferListPtr = outBufferList;
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {

        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {

            int frameOffset = int(frameIndex + bufferOffset);

            attackTime = attackTimeRamper.getAndStep();
            *vocoder->atk = (float)attackTime;
            releaseTime = releaseTimeRamper.getAndStep();
            *vocoder->rel = (float)releaseTime;
            bandwidthRatio = bandwidthRatioRamper.getAndStep();
            *vocoder->bwratio = (float)bandwidthRatio;

            for (int channel = 0; channel < channels; ++channel) {
                float *in  = (float *)inBufferListPtr->mBuffers[channel].mData  + frameOffset;
                float *excite = (float *)exciteBufferListPtr->mBuffers[channel].mData + frameOffset;
                float *out = (float *)outBufferListPtr->mBuffers[channel].mData + frameOffset;

                if (started) {
                    sp_vocoder_compute(sp, vocoder, excite, in, out);
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
    AudioBufferList *exciteBufferListPtr = nullptr;
    AudioBufferList *outBufferListPtr = nullptr;

    sp_data *sp;
    sp_vocoder *vocoder;

    float attackTime = 0.1;
    float releaseTime = 0.1;
    float bandwidthRatio = 0.5;

public:
    bool started = true;
    bool resetted = false;
    ParameterRamper attackTimeRamper = 0.1;
    ParameterRamper releaseTimeRamper = 0.1;
    ParameterRamper bandwidthRatioRamper = 0.5;
};

#endif /* AKVocoderDSPKernel_hpp */
