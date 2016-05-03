//
//  AKFormantFilterDSPKernel.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKFormantFilterDSPKernel_hpp
#define AKFormantFilterDSPKernel_hpp

#import "DSPKernel.hpp"
#import "ParameterRamper.hpp"

#import <AudioKit/AudioKit-Swift.h>

extern "C" {
#include "soundpipe.h"
}

enum {
    centerFrequencyAddress = 0,
    attackDurationAddress = 1,
    decayDurationAddress = 2
};

class AKFormantFilterDSPKernel : public DSPKernel {
public:
    // MARK: Member Functions

    AKFormantFilterDSPKernel() {}

    void init(int channelCount, double inSampleRate) {
        channels = channelCount;

        sampleRate = float(inSampleRate);

        sp_create(&sp);
        sp->sr = sampleRate;
        sp->nchan = channels;
        sp_fofilt_create(&fofilt);
        sp_fofilt_init(sp, fofilt);
        fofilt->freq = 1000;
        fofilt->atk = 0.007;
        fofilt->dec = 0.04;
    }

    void start() {
        started = true;
    }

    void stop() {
        started = false;
    }

    void destroy() {
        sp_fofilt_destroy(&fofilt);
        sp_destroy(&sp);
    }

    void reset() {
        resetted = true;
    }

    void setCenterFrequency(float freq) {
        centerFrequency = freq;
        centerFrequencyRamper.setImmediate(freq);
    }

    void setAttackDuration(float atk) {
        attackDuration = atk;
        attackDurationRamper.setImmediate(atk);
    }

    void setDecayDuration(float dec) {
        decayDuration = dec;
        decayDurationRamper.setImmediate(dec);
    }


    void setParameter(AUParameterAddress address, AUValue value) {
        switch (address) {
            case centerFrequencyAddress:
                centerFrequencyRamper.setUIValue(clamp(value, (float)12.0, (float)20000.0));
                break;

            case attackDurationAddress:
                attackDurationRamper.setUIValue(clamp(value, (float)0.0, (float)0.1));
                break;

            case decayDurationAddress:
                decayDurationRamper.setUIValue(clamp(value, (float)0.0, (float)0.1));
                break;

        }
    }

    AUValue getParameter(AUParameterAddress address) {
        switch (address) {
            case centerFrequencyAddress:
                return centerFrequencyRamper.getUIValue();

            case attackDurationAddress:
                return attackDurationRamper.getUIValue();

            case decayDurationAddress:
                return decayDurationRamper.getUIValue();

            default: return 0.0f;
        }
    }

    void startRamp(AUParameterAddress address, AUValue value, AUAudioFrameCount duration) override {
        switch (address) {
            case centerFrequencyAddress:
                centerFrequencyRamper.startRamp(clamp(value, (float)12.0, (float)20000.0), duration);
                break;

            case attackDurationAddress:
                attackDurationRamper.startRamp(clamp(value, (float)0.0, (float)0.1), duration);
                break;

            case decayDurationAddress:
                decayDurationRamper.startRamp(clamp(value, (float)0.0, (float)0.1), duration);
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

            centerFrequency = centerFrequencyRamper.getAndStep();
            fofilt->freq = (float)centerFrequency;
            attackDuration = attackDurationRamper.getAndStep();
            fofilt->atk = (float)attackDuration;
            decayDuration = decayDurationRamper.getAndStep();
            fofilt->dec = (float)decayDuration;

            if (!started) {
                outBufferListPtr->mBuffers[0] = inBufferListPtr->mBuffers[0];
                outBufferListPtr->mBuffers[1] = inBufferListPtr->mBuffers[1];
                return;
            }
            for (int channel = 0; channel < channels; ++channel) {
                float *in  = (float *)inBufferListPtr->mBuffers[channel].mData  + frameOffset;
                float *out = (float *)outBufferListPtr->mBuffers[channel].mData + frameOffset;

                sp_fofilt_compute(sp, fofilt, in, out);
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
    sp_fofilt *fofilt;

    float centerFrequency = 1000;
    float attackDuration = 0.007;
    float decayDuration = 0.04;

public:
    bool started = true;
    bool resetted = false;
    ParameterRamper centerFrequencyRamper = 1000;
    ParameterRamper attackDurationRamper = 0.007;
    ParameterRamper decayDurationRamper = 0.04;
};

#endif /* AKFormantFilterDSPKernel_hpp */
