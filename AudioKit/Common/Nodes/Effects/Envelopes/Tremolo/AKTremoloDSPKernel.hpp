//
//  AKTremoloDSPKernel.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKTremoloDSPKernel_hpp
#define AKTremoloDSPKernel_hpp

#import "DSPKernel.hpp"
#import "ParameterRamper.hpp"

#import <AudioKit/AudioKit-Swift.h>

extern "C" {
#include "soundpipe.h"
}

enum {
    frequencyAddress = 0
};

class AKTremoloDSPKernel : public DSPKernel {
public:
    // MARK: Member Functions

    AKTremoloDSPKernel() {}

    void init(int channelCount, double inSampleRate) {
        channels = channelCount;

        sampleRate = float(inSampleRate);

        sp_create(&sp);
        sp->sr = sampleRate;
        sp->nchan = channels;
        sp_trem_create(&trem);
        sp_trem_init(sp, trem, tbl);
        trem->freq = 10;
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
        sp_trem_destroy(&trem);
        sp_destroy(&sp);
    }

    void reset() {
        resetted = true;
    }

    void setFrequency(float freq) {
        frequency = freq;
        frequencyRamper.setImmediate(freq);
    }


    void setParameter(AUParameterAddress address, AUValue value) {
        switch (address) {
            case frequencyAddress:
                frequencyRamper.setUIValue(clamp(value, (float)0, (float)100));
                break;

        }
    }

    AUValue getParameter(AUParameterAddress address) {
        switch (address) {
            case frequencyAddress:
                return frequencyRamper.getUIValue();

            default: return 0.0f;
        }
    }

    void startRamp(AUParameterAddress address, AUValue value, AUAudioFrameCount duration) override {
        switch (address) {
            case frequencyAddress:
                frequencyRamper.startRamp(clamp(value, (float)0, (float)100), duration);
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

            frequency = frequencyRamper.getAndStep();
            trem->freq = (float)frequency * 0.5; //Divide by two for stereo

            if (!started) {
                outBufferListPtr->mBuffers[0] = inBufferListPtr->mBuffers[0];
                outBufferListPtr->mBuffers[1] = inBufferListPtr->mBuffers[1];
                return;
            }
            for (int channel = 0; channel < channels; ++channel) {
                float *in  = (float *)inBufferListPtr->mBuffers[channel].mData  + frameOffset;
                float *out = (float *)outBufferListPtr->mBuffers[channel].mData + frameOffset;

                sp_trem_compute(sp, trem, in, out);
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
    sp_trem *trem;
    sp_ftbl *tbl;
    UInt32 tbl_size = 4096;

    float frequency = 10;

public:
    bool started = true;
    bool resetted = false;
    ParameterRamper frequencyRamper = 10;
};

#endif /* AKTremoloDSPKernel_hpp */
