//
//  AKEqualizerFilterDSPKernel.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

#pragma once

#import "AKSoundpipeKernel.hpp"

enum {
    centerFrequencyAddress = 0,
    bandwidthAddress = 1,
    gainAddress = 2
};

class AKEqualizerFilterDSPKernel : public AKSoundpipeKernel, public AKBuffered {
public:
    // MARK: Member Functions

    AKEqualizerFilterDSPKernel() {}

    void init(int _channels, double _sampleRate) override {
        AKSoundpipeKernel::init(_channels, _sampleRate);

        sp_eqfil_create(&eqfil0);
        sp_eqfil_create(&eqfil1);
        sp_eqfil_init(sp, eqfil0);
        sp_eqfil_init(sp, eqfil1);
        eqfil0->freq = 1000.0;
        eqfil1->freq = 1000.0;
        eqfil0->bw = 100.0;
        eqfil1->bw = 100.0;
        eqfil0->gain = 10.0;
        eqfil1->gain = 10.0;

        centerFrequencyRamper.init();
        bandwidthRamper.init();
        gainRamper.init();
    }

    void start() {
        started = true;
    }

    void stop() {
        started = false;
    }

    void destroy() {
        sp_eqfil_destroy(&eqfil0);
        sp_eqfil_destroy(&eqfil1);
        AKSoundpipeKernel::destroy();
    }

    void reset() {
        resetted = true;
        centerFrequencyRamper.reset();
        bandwidthRamper.reset();
        gainRamper.reset();
    }

    void setCenterFrequency(float value) {
        centerFrequency = clamp(value, 12.0f, 20000.0f);
        centerFrequencyRamper.setImmediate(centerFrequency);
    }

    void setBandwidth(float value) {
        bandwidth = clamp(value, 0.0f, 20000.0f);
        bandwidthRamper.setImmediate(bandwidth);
    }

    void setGain(float value) {
        gain = clamp(value, -100.0f, 100.0f);
        gainRamper.setImmediate(gain);
    }


    void setParameter(AUParameterAddress address, AUValue value) {
        switch (address) {
            case centerFrequencyAddress:
                centerFrequencyRamper.setUIValue(clamp(value, 12.0f, 20000.0f));
                break;

            case bandwidthAddress:
                bandwidthRamper.setUIValue(clamp(value, 0.0f, 20000.0f));
                break;

            case gainAddress:
                gainRamper.setUIValue(clamp(value, -100.0f, 100.0f));
                break;

        }
    }

    AUValue getParameter(AUParameterAddress address) {
        switch (address) {
            case centerFrequencyAddress:
                return centerFrequencyRamper.getUIValue();

            case bandwidthAddress:
                return bandwidthRamper.getUIValue();

            case gainAddress:
                return gainRamper.getUIValue();

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

            case gainAddress:
                gainRamper.startRamp(clamp(value, -100.0f, 100.0f), duration);
                break;

        }
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {

        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {

            int frameOffset = int(frameIndex + bufferOffset);

            centerFrequency = centerFrequencyRamper.getAndStep();
            eqfil0->freq = (float)centerFrequency;
            eqfil1->freq = (float)centerFrequency;
            bandwidth = bandwidthRamper.getAndStep();
            eqfil0->bw = (float)bandwidth;
            eqfil1->bw = (float)bandwidth;
            gain = gainRamper.getAndStep();
            eqfil0->gain = (float)gain;
            eqfil1->gain = (float)gain;

            for (int channel = 0; channel < channels; ++channel) {
                float *in  = (float *)inBufferListPtr->mBuffers[channel].mData  + frameOffset;
                float *out = (float *)outBufferListPtr->mBuffers[channel].mData + frameOffset;

                if (started) {
                    if (channel == 0) {
                        sp_eqfil_compute(sp, eqfil0, in, out);
                    } else {
                        sp_eqfil_compute(sp, eqfil1, in, out);
                    }
                } else {
                    *out = *in;
                }
            }
        }
    }

    // MARK: Member Variables

private:

    sp_eqfil *eqfil0;
    sp_eqfil *eqfil1;

    float centerFrequency = 1000.0;
    float bandwidth = 100.0;
    float gain = 10.0;

public:
    bool started = true;
    bool resetted = false;
    ParameterRamper centerFrequencyRamper = 1000.0;
    ParameterRamper bandwidthRamper = 100.0;
    ParameterRamper gainRamper = 10.0;
};
