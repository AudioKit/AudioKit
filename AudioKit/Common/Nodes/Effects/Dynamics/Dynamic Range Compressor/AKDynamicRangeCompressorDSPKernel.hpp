//
//  AKDynamicRangeCompressorDSPKernel.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

#pragma once

#import "DSPKernel.hpp"
#import "ParameterRamper.hpp"

#import <AudioKit/AudioKit-Swift.h>

extern "C" {
#include "soundpipe.h"
}

enum {
    ratioAddress = 0,
    thresholdAddress = 1,
    attackTimeAddress = 2,
    releaseTimeAddress = 3
};

class AKDynamicRangeCompressorDSPKernel : public AKSoundpipeKernel, public AKBuffered {
public:
    // MARK: Member Functions

    AKDynamicRangeCompressorDSPKernel() {}

    void init(int _channels, double _sampleRate) override {
        AKSoundpipeKernel::init(_channels, _sampleRate);

        sp_compressor_create(&compressor0);
        sp_compressor_create(&compressor1);
        sp_compressor_init(sp, compressor0);
        sp_compressor_init(sp, compressor1);
        *compressor0->ratio = 1;
        *compressor1->ratio = 1;
        *compressor0->thresh = 0.0;
        *compressor1->thresh = 0.0;
        *compressor0->atk = 0.1;
        *compressor1->atk = 0.1;
        *compressor0->rel = 0.1;
        *compressor1->rel = 0.1;

        ratioRamper.init();
        thresholdRamper.init();
        attackTimeRamper.init();
        releaseTimeRamper.init();
    }

    void start() {
        started = true;
    }

    void stop() {
        started = false;
    }

    void destroy() {
        sp_compressor_destroy(&compressor0);
        sp_compressor_destroy(&compressor1);
        AKSoundpipeKernel::destroy();
    }

    void reset() {
        resetted = true;
        ratioRamper.reset();
        thresholdRamper.reset();
        attackTimeRamper.reset();
        releaseTimeRamper.reset();
    }

    void setRatio(float value) {
        ratio = clamp(value, 0.01f, 100.0f);
        ratioRamper.setImmediate(ratio);
    }

    void setThreshold(float value) {
        threshold = clamp(value, -100.0f, 0.0f);
        thresholdRamper.setImmediate(threshold);
    }

    void setAttackTime(float value) {
        attackTime = clamp(value, 0.0f, 1.0f);
        attackTimeRamper.setImmediate(attackTime);
    }

    void setReleaseTime(float value) {
        releaseTime = clamp(value, 0.0f, 1.0f);
        releaseTimeRamper.setImmediate(releaseTime);
    }


    void setParameter(AUParameterAddress address, AUValue value) {
        switch (address) {
            case ratioAddress:
                ratioRamper.setUIValue(clamp(value, 0.01f, 100.0f));
                break;

            case thresholdAddress:
                thresholdRamper.setUIValue(clamp(value, -100.0f, 0.0f));
                break;

            case attackTimeAddress:
                attackTimeRamper.setUIValue(clamp(value, 0.0f, 1.0f));
                break;

            case releaseTimeAddress:
                releaseTimeRamper.setUIValue(clamp(value, 0.0f, 1.0f));
                break;

        }
    }

    AUValue getParameter(AUParameterAddress address) {
        switch (address) {
            case ratioAddress:
                return ratioRamper.getUIValue();

            case thresholdAddress:
                return thresholdRamper.getUIValue();

            case attackTimeAddress:
                return attackTimeRamper.getUIValue();

            case releaseTimeAddress:
                return releaseTimeRamper.getUIValue();

            default: return 0.0f;
        }
    }

    void startRamp(AUParameterAddress address, AUValue value, AUAudioFrameCount duration) override {
        switch (address) {
            case ratioAddress:
                ratioRamper.startRamp(clamp(value, 0.01f, 100.0f), duration);
                break;

            case thresholdAddress:
                thresholdRamper.startRamp(clamp(value, -100.0f, 0.0f), duration);
                break;

            case attackTimeAddress:
                attackTimeRamper.startRamp(clamp(value, 0.0f, 1.0f), duration);
                break;

            case releaseTimeAddress:
                releaseTimeRamper.startRamp(clamp(value, 0.0f, 1.0f), duration);
                break;

        }
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {

        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {

            int frameOffset = int(frameIndex + bufferOffset);

            ratio = ratioRamper.getAndStep();
            *compressor0->ratio = (float)ratio;
            *compressor1->ratio = (float)ratio;
            threshold = thresholdRamper.getAndStep();
            *compressor0->thresh = (float)threshold;
            *compressor1->thresh = (float)threshold;
            attackTime = attackTimeRamper.getAndStep();
            *compressor0->atk = (float)attackTime;
            *compressor1->atk = (float)attackTime;
            releaseTime = releaseTimeRamper.getAndStep();
            *compressor0->rel = (float)releaseTime;
            *compressor1->rel = (float)releaseTime;

            for (int channel = 0; channel < channels; ++channel) {
                float *in  = (float *)inBufferListPtr->mBuffers[channel].mData  + frameOffset;
                float *out = (float *)outBufferListPtr->mBuffers[channel].mData + frameOffset;

                if (started) {
                    if (channel == 0) {
                        sp_compressor_compute(sp, compressor0, in, out);
                    } else {
                        sp_compressor_compute(sp, compressor1, in, out);
                    }
                } else {
                    *out = *in;
                }
            }
        }
    }

    // MARK: Member Variables

private:

    sp_compressor *compressor0;
    sp_compressor *compressor1;

    float ratio = 1;
    float threshold = 0.0;
    float attackTime = 0.1;
    float releaseTime = 0.1;

public:
    bool started = true;
    bool resetted = false;
    ParameterRamper ratioRamper = 1;
    ParameterRamper thresholdRamper = 0.0;
    ParameterRamper attackTimeRamper = 0.1;
    ParameterRamper releaseTimeRamper = 0.1;
};
