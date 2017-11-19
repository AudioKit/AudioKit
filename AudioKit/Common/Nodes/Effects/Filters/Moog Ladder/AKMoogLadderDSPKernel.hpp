//
//  AKMoogLadderDSPKernel.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

#pragma once

#import "AKSoundpipeKernel.hpp"

enum {
    cutoffFrequencyAddress = 0,
    resonanceAddress = 1
};

class AKMoogLadderDSPKernel : public AKSoundpipeKernel, public AKBuffered {
public:
    // MARK: Member Functions

    AKMoogLadderDSPKernel() {}

    void init(int _channels, double _sampleRate) override {
        AKSoundpipeKernel::init(_channels, _sampleRate);

        sp_moogladder_create(&moogladder0);
        sp_moogladder_create(&moogladder1);
        sp_moogladder_init(sp, moogladder0);
        sp_moogladder_init(sp, moogladder1);
        moogladder0->freq = 1000;
        moogladder1->freq = 1000;
        moogladder0->res = 0.5;
        moogladder1->res = 0.5;

        cutoffFrequencyRamper.init();
        resonanceRamper.init();
    }

    void start() {
        started = true;
    }

    void stop() {
        started = false;
    }

    void destroy() {
        sp_moogladder_destroy(&moogladder0);
        sp_moogladder_destroy(&moogladder1);
        AKSoundpipeKernel::destroy();
    }

    void reset() {
        resetted = true;
        cutoffFrequencyRamper.reset();
        resonanceRamper.reset();
    }

    void setCutoffFrequency(float value) {
        cutoffFrequency = clamp(value, 12.0f, 20000.0f);
        cutoffFrequencyRamper.setImmediate(cutoffFrequency);
    }

    void setResonance(float value) {
        resonance = clamp(value, 0.0f, 2.0f);
        resonanceRamper.setImmediate(resonance);
    }


    void setParameter(AUParameterAddress address, AUValue value) {
        switch (address) {
            case cutoffFrequencyAddress:
                cutoffFrequencyRamper.setUIValue(clamp(value, 12.0f, 20000.0f));
                break;

            case resonanceAddress:
                resonanceRamper.setUIValue(clamp(value, 0.0f, 2.0f));
                break;

        }
    }

    AUValue getParameter(AUParameterAddress address) {
        switch (address) {
            case cutoffFrequencyAddress:
                return cutoffFrequencyRamper.getUIValue();

            case resonanceAddress:
                return resonanceRamper.getUIValue();

            default: return 0.0f;
        }
    }

    void startRamp(AUParameterAddress address, AUValue value, AUAudioFrameCount duration) override {
        switch (address) {
            case cutoffFrequencyAddress:
                cutoffFrequencyRamper.startRamp(clamp(value, 12.0f, 20000.0f), duration);
                break;

            case resonanceAddress:
                resonanceRamper.startRamp(clamp(value, 0.0f, 2.0f), duration);
                break;

        }
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {

        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {

            int frameOffset = int(frameIndex + bufferOffset);

            cutoffFrequency = cutoffFrequencyRamper.getAndStep();
            moogladder0->freq = (float)cutoffFrequency;
            moogladder1->freq = (float)cutoffFrequency;
            resonance = resonanceRamper.getAndStep();
            moogladder0->res = (float)resonance;
            moogladder1->res = (float)resonance;

            for (int channel = 0; channel < channels; ++channel) {
                float *in  = (float *)inBufferListPtr->mBuffers[channel].mData  + frameOffset;
                float *out = (float *)outBufferListPtr->mBuffers[channel].mData + frameOffset;

                if (started) {
                    if (channel == 0) {
                        sp_moogladder_compute(sp, moogladder0, in, out);
                    } else {
                        sp_moogladder_compute(sp, moogladder1, in, out);
                    }
                } else {
                    *out = *in;
                }
            }
        }
    }

    // MARK: Member Variables

private:

    sp_moogladder *moogladder0;
    sp_moogladder *moogladder1;

    float cutoffFrequency = 1000;
    float resonance = 0.5;

public:
    bool started = true;
    bool resetted = false;
    ParameterRamper cutoffFrequencyRamper = 1000;
    ParameterRamper resonanceRamper = 0.5;
};
