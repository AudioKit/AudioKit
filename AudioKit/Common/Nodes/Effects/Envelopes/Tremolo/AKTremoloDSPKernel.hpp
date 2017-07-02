//
//  AKTremoloDSPKernel.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

#pragma once

#import "AKSoundpipeKernel.hpp"
#import "ParameterRamper.hpp"

#import <AudioKit/AudioKit-Swift.h>

extern "C" {
#include "soundpipe.h"
}

enum {
    frequencyAddress = 0,
    depthAddress = 1
    
};

class AKTremoloDSPKernel : public AKSoundpipeKernel, public AKBuffered {
public:
    // MARK: Member Functions

    AKTremoloDSPKernel() {}

    void init(int _channels, double _sampleRate) override {
        AKSoundpipeKernel::init(_channels, _sampleRate);
        sp_osc_create(&trem);
        sp_osc_init(sp, trem, tbl, 0);
        trem->freq = 10;
        trem->amp = 1;

        frequencyRamper.init();
        depthRamper.init();
    }
    void setupWaveform(uint32_t size) {
        tbl_size = size;
        sp_ftbl_create(sp, &tbl, tbl_size);
    }

    void setWaveformValue(uint32_t index, float value) {
        tbl->tbl[index] = value;
    }

    void start() {
        started = true;
    }

    void stop() {
        started = false;
    }

    void destroy() {
        sp_osc_destroy(&trem);
        AKSoundpipeKernel::destroy();
    }

    void reset() {
        resetted = true;
        frequencyRamper.reset();
        depthRamper.reset();
    }

    void setFrequency(float value) {
        frequency = clamp(value, 0.0f, 100.0f);
        frequencyRamper.setImmediate(frequency);
    }
    
    void setDepth(float value) {
        depth = clamp(value, 0.0f, 2.0f);
        depthRamper.setImmediate(depth);
    }

    void setParameter(AUParameterAddress address, AUValue value) {
        switch (address) {
            case frequencyAddress:
                frequencyRamper.setUIValue(clamp(value, 0.0f, 100.0f));
                break;
            case depthAddress:
                depthRamper.setUIValue(clamp(value, 0.0f, 2.0f));
                break;

        }
    }

    AUValue getParameter(AUParameterAddress address) {
        switch (address) {
            case frequencyAddress:
                return frequencyRamper.getUIValue();
            case depthAddress:
                return depthRamper.getUIValue();

            default: return 0.0f;
        }
    }

    void startRamp(AUParameterAddress address, AUValue value, AUAudioFrameCount duration) override {
        switch (address) {
            case frequencyAddress:
                frequencyRamper.startRamp(clamp(value, 0.0f, 100.0f), duration);
                break;
            case depthAddress:
                depthRamper.startRamp(clamp(value, 0.0f, 2.0f), duration);
                break;

        }
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {

        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {

            int frameOffset = int(frameIndex + bufferOffset);

            frequency = frequencyRamper.getAndStep();
            trem->freq = (float)frequency * 0.5; //Divide by two for stereo
            
            depth = depthRamper.getAndStep();
            trem->amp = (float)depth;

            float temp = 0;
            for (int channel = 0; channel < channels; ++channel) {
                float *in  = (float *)inBufferListPtr->mBuffers[channel].mData  + frameOffset;
                float *out = (float *)outBufferListPtr->mBuffers[channel].mData + frameOffset;

                if (started) {
                    sp_osc_compute(sp, trem, NULL, &temp);
                    *out = *in * (1.0 - temp);
                } else {
                    *out = *in;
                }
            }
        }
    }

    // MARK: Member Variables

private:

    sp_osc *trem;
    sp_ftbl *tbl;
    UInt32 tbl_size = 4096;

    float frequency = 10.0;
    float depth = 1.0;

public:
    bool started = true;
    bool resetted = false;
    ParameterRamper frequencyRamper = 10.0;
    ParameterRamper depthRamper = 10.0;
};

