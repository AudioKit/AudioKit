//
//  AKLowPassButterworthFilterDSPKernel.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

#pragma once

#import "AKSoundpipeKernel.hpp"

enum {
    cutoffFrequencyAddress = 0
};

class AKLowPassButterworthFilterDSPKernel : public AKSoundpipeKernel, public AKBuffered {
public:
    // MARK: Member Functions

    AKLowPassButterworthFilterDSPKernel() {}

    void init(int _channels, double _sampleRate) override {
        AKSoundpipeKernel::init(_channels, _sampleRate);

        sp_butlp_create(&butlp0);
        sp_butlp_create(&butlp1);
        sp_butlp_init(sp, butlp0);
        sp_butlp_init(sp, butlp1);
        butlp0->freq = 1000.0;
        butlp1->freq = 1000.0;

        cutoffFrequencyRamper.init();
    }

    void start() {
        started = true;
    }

    void stop() {
        started = false;
    }

    void destroy() {
        sp_butlp_destroy(&butlp0);
        sp_butlp_destroy(&butlp1);
        AKSoundpipeKernel::destroy();
    }

    void reset() {
        resetted = true;
        cutoffFrequencyRamper.reset();
    }

    void setCutoffFrequency(float value) {
        cutoffFrequency = clamp(value, 12.0f, 20000.0f);
        cutoffFrequencyRamper.setImmediate(cutoffFrequency);
    }


    void setParameter(AUParameterAddress address, AUValue value) {
        switch (address) {
            case cutoffFrequencyAddress:
                cutoffFrequencyRamper.setUIValue(clamp(value, 12.0f, 20000.0f));
                break;

        }
    }

    AUValue getParameter(AUParameterAddress address) {
        switch (address) {
            case cutoffFrequencyAddress:
                return cutoffFrequencyRamper.getUIValue();

            default: return 0.0f;
        }
    }

    void startRamp(AUParameterAddress address, AUValue value, AUAudioFrameCount duration) override {
        switch (address) {
            case cutoffFrequencyAddress:
                cutoffFrequencyRamper.startRamp(clamp(value, 12.0f, 20000.0f), duration);
                break;

        }
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {

        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {

            int frameOffset = int(frameIndex + bufferOffset);

            cutoffFrequency = cutoffFrequencyRamper.getAndStep();
            butlp0->freq = (float)cutoffFrequency;
            butlp1->freq = (float)cutoffFrequency;

            for (int channel = 0; channel < channels; ++channel) {
                float *in  = (float *)inBufferListPtr->mBuffers[channel].mData  + frameOffset;
                float *out = (float *)outBufferListPtr->mBuffers[channel].mData + frameOffset;

                if (started) {
                    if (channel == 0) {
                        sp_butlp_compute(sp, butlp0, in, out);
                    } else {
                        sp_butlp_compute(sp, butlp1, in, out);
                    }
                } else {
                    *out = *in;
                }
            }
        }
    }

    // MARK: Member Variables

private:

    sp_butlp *butlp0;
    sp_butlp *butlp1;

    float cutoffFrequency = 1000.0;

public:
    bool started = true;
    bool resetted = false;
    ParameterRamper cutoffFrequencyRamper = 1000.0;
};
