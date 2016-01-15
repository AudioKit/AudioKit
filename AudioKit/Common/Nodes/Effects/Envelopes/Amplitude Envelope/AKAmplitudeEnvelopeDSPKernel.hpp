//
//  AKAmplitudeEnvelopeDSPKernel.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKAmplitudeEnvelopeDSPKernel_hpp
#define AKAmplitudeEnvelopeDSPKernel_hpp

#import "AKDSPKernel.hpp"
#import "AKParameterRamper.hpp"

extern "C" {
#include "soundpipe.h"
}

enum {
    attackDurationAddress = 0,
    decayDurationAddress = 1,
    sustainLevelAddress = 2,
    releaseDurationAddress = 3
};

class AKAmplitudeEnvelopeDSPKernel : public AKDSPKernel {
public:
    // MARK: Member Functions

    AKAmplitudeEnvelopeDSPKernel() {}

    void init(int channelCount, double inSampleRate) {
        channels = channelCount;

        sampleRate = float(inSampleRate);

        sp_create(&sp);
        sp_tadsr_create(&tadsr);
        sp_tadsr_init(sp, tadsr);
        tadsr->atk = 0.1;
        tadsr->dec = 0.1;
        tadsr->sus = 0.8;
        tadsr->rel = 0.7;
    }

    void start() {
        if (!started) {
            internalTrigger = 1;
            started = true;
        }
    }

    void stop() {
        if (started) {
            internalTrigger = 2;
            started = false;
        }
        
    }

    void destroy() {
        sp_tadsr_destroy(&tadsr);
        sp_destroy(&sp);
    }

    void reset() {
    }

    void setParameter(AUParameterAddress address, AUValue value) {
        return;
        switch (address) {
            case attackDurationAddress:
                attackDurationRamper.set(clamp(value, (float)0, (float)99));
                break;

            case decayDurationAddress:
                decayDurationRamper.set(clamp(value, (float)0, (float)99));
                break;

            case sustainLevelAddress:
                sustainLevelRamper.set(clamp(value, (float)0, (float)99));
                break;

            case releaseDurationAddress:
                releaseDurationRamper.set(clamp(value, (float)0, (float)99));
                break;

        }
    }

    AUValue getParameter(AUParameterAddress address) {
        switch (address) {
            case attackDurationAddress:
                return attackDurationRamper.goal();

            case decayDurationAddress:
                return decayDurationRamper.goal();

            case sustainLevelAddress:
                return sustainLevelRamper.goal();

            case releaseDurationAddress:
                return releaseDurationRamper.goal();

            default: return 0.0f;
        }
    }

    void startRamp(AUParameterAddress address, AUValue value, AUAudioFrameCount duration) override {
        switch (address) {
            case attackDurationAddress:
                attackDurationRamper.startRamp(clamp(value, (float)0, (float)99), duration);
                break;

            case decayDurationAddress:
                decayDurationRamper.startRamp(clamp(value, (float)0, (float)99), duration);
                break;

            case sustainLevelAddress:
                sustainLevelRamper.startRamp(clamp(value, (float)0, (float)99), duration);
                break;

            case releaseDurationAddress:
                releaseDurationRamper.startRamp(clamp(value, (float)0, (float)99), duration);
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
            double attackDuration = double(attackDurationRamper.getStep());
            double decayDuration = double(decayDurationRamper.getStep());
            double sustainLevel = double(sustainLevelRamper.getStep());
            double releaseDuration = double(releaseDurationRamper.getStep());

            int frameOffset = int(frameIndex + bufferOffset);

            tadsr->atk = (float)attackDuration;
            tadsr->dec = (float)decayDuration;
            tadsr->sus = (float)sustainLevel;
            tadsr->rel = (float)releaseDuration;

            sp_tadsr_compute(sp, tadsr, &internalTrigger, &amp);
            internalTrigger = 0;

            for (int channel = 0; channel < channels; ++channel) {
                float *in  = (float *)inBufferListPtr->mBuffers[channel].mData  + frameOffset;
                float *out = (float *)outBufferListPtr->mBuffers[channel].mData + frameOffset;
                *out = *in * amp;
            }
        }
    }

    // MARK: Member Variables

private:

    int channels = 2;
    float sampleRate = 44100.0;
    float internalTrigger = 0;
    float amp = 0;
    
    AudioBufferList *inBufferListPtr = nullptr;
    AudioBufferList *outBufferListPtr = nullptr;

    sp_data *sp;
    sp_tadsr *tadsr;

public:
    bool started = false;
    AKParameterRamper attackDurationRamper = 0.1;
    AKParameterRamper decayDurationRamper = 0.1;
    AKParameterRamper sustainLevelRamper = 0.55;
    AKParameterRamper releaseDurationRamper = 0.77;
};

#endif /* AKAmplitudeEnvelopeDSPKernel_hpp */
