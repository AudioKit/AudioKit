//
//  AKBrownianNoiseDSPKernel.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

#pragma once

#import "AKSoundpipeKernel.hpp"

enum {
    amplitudeAddress = 0
};

class AKBrownianNoiseDSPKernel : public AKSoundpipeKernel, public AKOutputBuffered {
public:
    // MARK: Member Functions

    AKBrownianNoiseDSPKernel() {}

    void init(int _channels, double _sampleRate) override {
        AKSoundpipeKernel::init(_channels, _sampleRate);

        sp_brown_create(&brown);
        sp_brown_init(sp, brown);

        amplitudeRamper.init();
    }

    void start() {
        started = true;
    }

    void stop() {
        started = false;
    }

    void destroy() {
        sp_brown_destroy(&brown);
        AKSoundpipeKernel::destroy();
    }

    void reset() {
        resetted = true;
        amplitudeRamper.reset();
    }

    void setAmplitude(float value) {
        amplitude = clamp(value, 0.0f, 1.0f);
        amplitudeRamper.setImmediate(amplitude);
    }


    void setParameter(AUParameterAddress address, AUValue value) {
        switch (address) {
            case amplitudeAddress:
                amplitudeRamper.setUIValue(clamp(value, 0.0f, 1.0f));
                break;

        }
    }

    AUValue getParameter(AUParameterAddress address) {
        switch (address) {
            case amplitudeAddress:
                return amplitudeRamper.getUIValue();

            default: return 0.0f;
        }
    }

    void startRamp(AUParameterAddress address, AUValue value, AUAudioFrameCount duration) override {
        switch (address) {
            case amplitudeAddress:
                amplitudeRamper.startRamp(clamp(value, 0.0f, 1.0f), duration);
                break;

        }
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {

        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {

            int frameOffset = int(frameIndex + bufferOffset);

            amplitude = amplitudeRamper.getAndStep();

            float temp = 0;
            for (int channel = 0; channel < channels; ++channel) {
                float *out = (float *)outBufferListPtr->mBuffers[channel].mData + frameOffset;
                if (started) {
                    if (channel == 0) {
                        sp_brown_compute(sp, brown, nil, &temp);
                    }
                    *out = amplitude * temp;
                } else {
                    *out = 0.0;
                }
            }
        }
    }

    // MARK: Member Variables

private:
    sp_brown *brown;

    float amplitude = 1;

public:
    bool started = false;
    bool resetted = false;
    ParameterRamper amplitudeRamper = 1;
};

