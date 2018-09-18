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

void *createPluckedStringDSP(int nChannels, double sampleRate);

#else

#import "AKSoundpipeDSPBase.hpp"

class AKPluckedStringDSP : public AKSoundpipeDSPBase {

    sp_pluck *_pluck;
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
                frequencyRamp.setRampDuration(value, _sampleRate);
                amplitudeRamp.setRampDuration(value, _sampleRate);
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
                return frequencyRamp.getRampDuration(_sampleRate);
        }
        return 0;
    }

    void init(int _channels, double _sampleRate) override {
        AKSoundpipeDSPBase::init(_channels, _sampleRate);

        sp_pluck_create(&_pluck);
        sp_pluck_init(_sp, _pluck, 110);
        _pluck->freq = 110;
        _pluck->amp = 0.5;
    }

    void deinit() override {
        sp_pluck_destroy(&_pluck);
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
                frequencyRamp.advanceTo(_now + frameOffset);
                amplitudeRamp.advanceTo(_now + frameOffset);
            }
            float frequency = frequencyRamp.getValue();
            float amplitude = amplitudeRamp.getValue();
            _pluck->freq = frequency;
            _pluck->amp = amplitude;

            for (int channel = 0; channel < _nChannels; ++channel) {
                float *out = (float *)_outBufferListPtr->mBuffers[channel].mData + frameOffset;

                if (_playing) {
                    if (channel == 0) {
                        sp_pluck_compute(_sp, _pluck, &internalTrigger, out);
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
