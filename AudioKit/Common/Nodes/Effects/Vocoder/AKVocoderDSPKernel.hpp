//
//  AKVocoderDSPKernel.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKVocoderDSPKernel_hpp
#define AKVocoderDSPKernel_hpp

#import "AKDSPKernel.hpp"
#import "AKParameterRamper.hpp"

extern "C" {
#include "soundpipe.h"
}

enum {
    attackTimeAddress = 0,
    relAddress = 1,
    bandwidthRatioAddress = 2
};

class AKVocoderDSPKernel : public AKDSPKernel {
public:
    // MARK: Member Functions

    AKVocoderDSPKernel() {}

    void init(int channelCount, double inSampleRate) {
        channels = channelCount;

        sampleRate = float(inSampleRate);

        sp_create(&sp);
        sp_vocoder_create(&vocoder);
        sp_vocoder_init(sp, vocoder);
        vocoder->atk = 0.1;
        vocoder->rel = 0.1;
        vocoder->bwratio = 0.5;
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
    }

    void setAttacktime(float atk) {
        attackTime = atk;
        attackTimeRamper.set(clamp(atk, (float)0.001, (float)0.5));
    }

    void setRel(float rel) {
        rel = rel;
        relRamper.set(clamp(rel, (float)0.001, (float)0.5));
    }

    void setBandwidthratio(float bwratio) {
        bandwidthRatio = bwratio;
        bandwidthRatioRamper.set(clamp(bwratio, (float)0.1, (float)2));
    }


    void setParameter(AUParameterAddress address, AUValue value) {
        switch (address) {
            case attackTimeAddress:
                attackTimeRamper.set(clamp(value, (float)0.001, (float)0.5));
                break;

            case relAddress:
                relRamper.set(clamp(value, (float)0.001, (float)0.5));
                break;

            case bandwidthRatioAddress:
                bandwidthRatioRamper.set(clamp(value, (float)0.1, (float)2));
                break;

        }
    }

    AUValue getParameter(AUParameterAddress address) {
        switch (address) {
            case attackTimeAddress:
                return attackTimeRamper.goal();

            case relAddress:
                return relRamper.goal();

            case bandwidthRatioAddress:
                return bandwidthRatioRamper.goal();

            default: return 0.0f;
        }
    }

    void startRamp(AUParameterAddress address, AUValue value, AUAudioFrameCount duration) override {
        switch (address) {
            case attackTimeAddress:
                attackTimeRamper.startRamp(clamp(value, (float)0.001, (float)0.5), duration);
                break;

            case relAddress:
                relRamper.startRamp(clamp(value, (float)0.001, (float)0.5), duration);
                break;

            case bandwidthRatioAddress:
                bandwidthRatioRamper.startRamp(clamp(value, (float)0.1, (float)2), duration);
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

            vocoder->atk = attackTimeRamper.getStep();
            vocoder->rel = relRamper.getStep();
            vocoder->bwratio = bandwidthRatioRamper.getStep();

            if (!started) {
                outBufferListPtr->mBuffers[0] = inBufferListPtr->mBuffers[0];
                outBufferListPtr->mBuffers[1] = inBufferListPtr->mBuffers[1];
                return;
            }
            for (int channel = 0; channel < channels; ++channel) {
                float *in  = (float *)inBufferListPtr->mBuffers[channel].mData  + frameOffset;
                float *out = (float *)outBufferListPtr->mBuffers[channel].mData + frameOffset;

                sp_vocoder_compute(sp, vocoder, in, out);
            }
        }
    }

    // MARK: Member Variables

private:

    int channels = 2;
    float sampleRate = 44100.0;

    AudioBufferList *inBufferListPtr = nullptr;
    AudioBufferList *outBufferListPtr = nullptr;

    sp_data *sp;
    sp_vocoder *vocoder;


    float attackTime = 0.1;
    float rel = 0.1;
    float bandwidthRatio = 0.5;

public:
    bool started = true;
    AKParameterRamper attackTimeRamper = 0.1;
    AKParameterRamper relRamper = 0.1;
    AKParameterRamper bandwidthRatioRamper = 0.5;
};

#endif /* AKVocoderDSPKernel_hpp */
