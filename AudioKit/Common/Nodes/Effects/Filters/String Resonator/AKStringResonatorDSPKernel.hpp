//
//  AKStringResonatorDSPKernel.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

#pragma once

#import "AKSoundpipeKernel.hpp"

enum {
    fundamentalFrequencyAddress = 0,
    feedbackAddress = 1
};

class AKStringResonatorDSPKernel : public AKSoundpipeKernel, public AKBuffered {
public:
    // MARK: Member Functions

    AKStringResonatorDSPKernel() {}

    void init(int _channels, double _sampleRate) override {
        AKSoundpipeKernel::init(_channels, _sampleRate);

        sp_streson_create(&streson0);
        sp_streson_create(&streson1);
        sp_streson_init(sp, streson0);
        sp_streson_init(sp, streson1);
        streson0->freq = 100;
        streson1->freq = 100;
        streson0->fdbgain = 0.95;
        streson1->fdbgain = 0.95;

        fundamentalFrequencyRamper.init();
        feedbackRamper.init();
    }

    void start() {
        started = true;
    }

    void stop() {
        started = false;
    }

    void destroy() {
        sp_streson_destroy(&streson0);
        sp_streson_destroy(&streson1);
        AKSoundpipeKernel::destroy();
    }

    void reset() {
        resetted = true;
        fundamentalFrequencyRamper.reset();
        feedbackRamper.reset();
    }

    void setFundamentalFrequency(float value) {
        fundamentalFrequency = clamp(value, 12.0f, 10000.0f);
        fundamentalFrequencyRamper.setImmediate(fundamentalFrequency);
    }

    void setFeedback(float value) {
        feedback = clamp(value, 0.0f, 1.0f);
        feedbackRamper.setImmediate(feedback);
    }


    void setParameter(AUParameterAddress address, AUValue value) {
        switch (address) {
            case fundamentalFrequencyAddress:
                fundamentalFrequencyRamper.setUIValue(clamp(value, 12.0f, 10000.0f));
                break;

            case feedbackAddress:
                feedbackRamper.setUIValue(clamp(value, 0.0f, 1.0f));
                break;

        }
    }

    AUValue getParameter(AUParameterAddress address) {
        switch (address) {
            case fundamentalFrequencyAddress:
                return fundamentalFrequencyRamper.getUIValue();

            case feedbackAddress:
                return feedbackRamper.getUIValue();

            default: return 0.0f;
        }
    }

    void startRamp(AUParameterAddress address, AUValue value, AUAudioFrameCount duration) override {
        switch (address) {
            case fundamentalFrequencyAddress:
                fundamentalFrequencyRamper.startRamp(clamp(value, 12.0f, 10000.0f), duration);
                break;

            case feedbackAddress:
                feedbackRamper.startRamp(clamp(value, 0.0f, 1.0f), duration);
                break;

        }
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {

        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {

            int frameOffset = int(frameIndex + bufferOffset);

            fundamentalFrequency = fundamentalFrequencyRamper.getAndStep();
            streson0->freq = (float)fundamentalFrequency;
            streson1->freq = (float)fundamentalFrequency;
            feedback = feedbackRamper.getAndStep();
            streson0->fdbgain = (float)feedback;
            streson1->fdbgain = (float)feedback;

            for (int channel = 0; channel < channels; ++channel) {
                float *in  = (float *)inBufferListPtr->mBuffers[channel].mData  + frameOffset;
                float *out = (float *)outBufferListPtr->mBuffers[channel].mData + frameOffset;

                if (started) {
                    if (channel == 0) {
                        sp_streson_compute(sp, streson0, in, out);
                    } else {
                        sp_streson_compute(sp, streson1, in, out);
                    }
                } else {
                    *out = *in;
                }
            }
        }
    }

    // MARK: Member Variables

private:

    sp_streson *streson0;
    sp_streson *streson1;

    float fundamentalFrequency = 100;
    float feedback = 0.95;

public:
    bool started = true;
    bool resetted = false;
    ParameterRamper fundamentalFrequencyRamper = 100;
    ParameterRamper feedbackRamper = 0.95;
};
