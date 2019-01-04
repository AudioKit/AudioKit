//
//  AKPluckedStringDSP.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once

#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(AUParameterAddress, AKPluckedStringParameter) {
    AKPluckedStringParameterFrequency,
    AKPluckedStringParameterAmplitude,
    AKPluckedStringParameterRampDuration
};

#import "AKLinearParameterRamp.hpp"  // have to put this here to get it included in umbrella header

#ifndef __cplusplus

AKDSPRef createPluckedStringDSP(int channelCount, double sampleRate);

#else

#import "AKSoundpipeDSPBase.hpp"

class AKPluckedStringDSP : public AKSoundpipeDSPBase {
    sp_pluck *pluck;
    float internalTrigger = 0;

private:
    AKLinearParameterRamp frequencyRamp;
    AKLinearParameterRamp amplitudeRamp;

public:
    AKPluckedStringDSP() {
        frequencyRamp.setTarget(110, true);
        frequencyRamp.setDurationInSamples(10000);
        amplitudeRamp.setTarget(0.5, true);
        amplitudeRamp.setDurationInSamples(10000);
    }

    /** Uses the ParameterAddress as a key */
    void setParameter(AUParameterAddress address, float value, bool immediate) override {
        switch (address) {
            case AKPluckedStringParameterFrequency:
                frequencyRamp.setTarget(value, immediate);
                break;
            case AKPluckedStringParameterAmplitude:
                amplitudeRamp.setTarget(value, immediate);
                break;
            case AKPluckedStringParameterRampDuration:
                frequencyRamp.setRampDuration(value, sampleRate);
                amplitudeRamp.setRampDuration(value, sampleRate);
                break;
        }
    }

    /** Uses the ParameterAddress as a key */
    float getParameter(AUParameterAddress address) override {
        switch (address) {
            case AKPluckedStringParameterFrequency:
                return frequencyRamp.getTarget();
            case AKPluckedStringParameterAmplitude:
                return amplitudeRamp.getTarget();
            case AKPluckedStringParameterRampDuration:
                return frequencyRamp.getRampDuration(sampleRate);
        }
        return 0;
    }

    void init(int channelCount, double sampleRate) override {
        AKSoundpipeDSPBase::init(channelCount, sampleRate);

        sp_pluck_create(&pluck);
        sp_pluck_init(sp, pluck, 110);
        pluck->freq = 110;
        pluck->amp = 0.5;
    }

    void deinit() override {
        sp_pluck_destroy(&pluck);
    }

    void trigger() override {
        internalTrigger = 1;
    }

    void triggerFrequencyAmplitude(AUValue freq, AUValue amp) override {
        bool immediate = true;
        frequencyRamp.setTarget(freq, immediate);
        amplitudeRamp.setTarget(amp, immediate);
        trigger();
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {

        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            int frameOffset = int(frameIndex + bufferOffset);

            // do ramping every 8 samples
            if ((frameOffset & 0x7) == 0) {
                frequencyRamp.advanceTo(now + frameOffset);
                amplitudeRamp.advanceTo(now + frameOffset);
            }
            float frequency = frequencyRamp.getValue();
            float amplitude = amplitudeRamp.getValue();
            pluck->freq = frequency;
            pluck->amp = amplitude;

            for (int channel = 0; channel < channelCount; ++channel) {
                float *out = (float *)outBufferListPtr->mBuffers[channel].mData + frameOffset;

                if (isStarted) {
                    if (channel == 0) {
                        sp_pluck_compute(sp, pluck, &internalTrigger, out);
                    }
                } else {
                    *out = 0.0;
                }
            }
        }
        if (internalTrigger == 1) {
            internalTrigger = 0;
        }
    }
};

#endif
