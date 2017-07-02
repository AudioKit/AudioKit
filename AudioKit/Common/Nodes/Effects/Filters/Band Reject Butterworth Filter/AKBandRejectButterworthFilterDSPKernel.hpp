//
//  AKBandRejectButterworthFilterDSPKernel.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

#pragma once

#import "AKSoundpipeKernel.hpp"

enum {
    centerFrequencyAddress = 0,
    bandwidthAddress = 1
};

class AKBandRejectButterworthFilterDSPKernel : public AKSoundpipeKernel, public AKBuffered {
public:
    // MARK: Member Functions

    AKBandRejectButterworthFilterDSPKernel() {}

    void init(int _channels, double _sampleRate) override {
        AKSoundpipeKernel::init(_channels, _sampleRate);

        sp_butbr_create(&butbr0);
        sp_butbr_create(&butbr1);
        sp_butbr_init(sp, butbr0);
        sp_butbr_init(sp, butbr1);
        butbr0->freq = 3000.0;
        butbr1->freq = 3000.0;
        butbr0->bw = 2000.0;
        butbr1->bw = 2000.0;

        centerFrequencyRamper.init();
        bandwidthRamper.init();
    }

    void start() {
        started = true;
    }

    void stop() {
        started = false;
    }

    void destroy() {
        sp_butbr_destroy(&butbr0);
        sp_butbr_destroy(&butbr1);
        AKSoundpipeKernel::destroy();
    }

    void reset() {
        resetted = true;
        centerFrequencyRamper.reset();
        bandwidthRamper.reset();
    }

    void setCenterFrequency(float value) {
        centerFrequency = clamp(value, 12.0f, 20000.0f);
        centerFrequencyRamper.setImmediate(centerFrequency);
    }

    void setBandwidth(float value) {
        bandwidth = clamp(value, 0.0f, 20000.0f);
        bandwidthRamper.setImmediate(bandwidth);
    }


    void setParameter(AUParameterAddress address, AUValue value) {
        switch (address) {
            case centerFrequencyAddress:
                centerFrequencyRamper.setUIValue(clamp(value, 12.0f, 20000.0f));
                break;

            case bandwidthAddress:
                bandwidthRamper.setUIValue(clamp(value, 0.0f, 20000.0f));
                break;

        }
    }

    AUValue getParameter(AUParameterAddress address) {
        switch (address) {
            case centerFrequencyAddress:
                return centerFrequencyRamper.getUIValue();

            case bandwidthAddress:
                return bandwidthRamper.getUIValue();

            default: return 0.0f;
        }
    }

    void startRamp(AUParameterAddress address, AUValue value, AUAudioFrameCount duration) override {
        switch (address) {
            case centerFrequencyAddress:
                centerFrequencyRamper.startRamp(clamp(value, 12.0f, 20000.0f), duration);
                break;

            case bandwidthAddress:
                bandwidthRamper.startRamp(clamp(value, 0.0f, 20000.0f), duration);
                break;

        }
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {

        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {

            int frameOffset = int(frameIndex + bufferOffset);

            centerFrequency = centerFrequencyRamper.getAndStep();
            butbr0->freq = (float)centerFrequency;
            butbr1->freq = (float)centerFrequency;
            bandwidth = bandwidthRamper.getAndStep();
            butbr0->bw = (float)bandwidth;
            butbr1->bw = (float)bandwidth;

            for (int channel = 0; channel < channels; ++channel) {
                float *in  = (float *)inBufferListPtr->mBuffers[channel].mData  + frameOffset;
                float *out = (float *)outBufferListPtr->mBuffers[channel].mData + frameOffset;

                if (started) {
                    if (channel == 0) {
                        sp_butbr_compute(sp, butbr0, in, out);
                    } else {
                        sp_butbr_compute(sp, butbr1, in, out);
                    }
                } else {
                    *out = *in;
                }
            }
        }
    }

    // MARK: Member Variables

private:

    sp_butbr *butbr0;
    sp_butbr *butbr1;

    float centerFrequency = 3000.0;
    float bandwidth = 2000.0;

public:
    bool started = true;
    bool resetted = false;
    ParameterRamper centerFrequencyRamper = 3000.0;
    ParameterRamper bandwidthRamper = 2000.0;
};
