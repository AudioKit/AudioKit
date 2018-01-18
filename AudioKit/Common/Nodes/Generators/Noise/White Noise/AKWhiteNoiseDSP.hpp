//
//  AKWhiteNoiseDSP.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once

#import <Foundation/Foundation.h>

typedef NS_ENUM(int64_t, AKWhiteNoiseParameter) {
    AKWhiteNoiseParameterAmplitude,
    AKWhiteNoiseParameterRampTime
};

#import "AKLinearParameterRamp.hpp"  // have to put this here to get it included in umbrella header

#ifndef __cplusplus

void* createWhiteNoiseDSP(int nChannels, double sampleRate);

#else

#import "AKSoundpipeDSPBase.hpp"

class AKWhiteNoiseDSP : public AKSoundpipeDSPBase {

    sp_noise *_noise;

private:
    AKLinearParameterRamp amplitudeRamp;

public:
    AKWhiteNoiseDSP() {
        amplitudeRamp.setTarget(1, true);
        amplitudeRamp.setDurationInSamples(10000);
    }

    /** Uses the ParameterAddress as a key */
    void setParameter(uint64_t address, float value, bool immediate) override {
        switch (address) {
            case AKWhiteNoiseParameterAmplitude:
                amplitudeRamp.setTarget(value, immediate);
                break;
            case AKWhiteNoiseParameterRampTime:
                amplitudeRamp.setRampTime(value, _sampleRate);
                break;
        }
    }

    /** Uses the ParameterAddress as a key */
    float getParameter(uint64_t address) override {
        switch (address) {
            case AKWhiteNoiseParameterAmplitude:
                return amplitudeRamp.getTarget();
            case AKWhiteNoiseParameterRampTime:
                return amplitudeRamp.getRampTime(_sampleRate);
        }
        return 0;
    }

    void init(int _channels, double _sampleRate) override {
        AKSoundpipeDSPBase::init(_channels, _sampleRate);

        sp_noise_create(&_noise);
        sp_noise_init(_sp, _noise);
        _noise->amp = 1;
    }

    void destroy() {
        sp_noise_destroy(&_noise);
        AKSoundpipeDSPBase::destroy();
    }


    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {

        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            int frameOffset = int(frameIndex + bufferOffset);

            // do gain ramping every 8 samples
            if ((frameOffset & 0x7) == 0) {
                amplitudeRamp.advanceTo(_now + frameOffset);
            }
            float amplitude = amplitudeRamp.getValue();
            _noise->amp = amplitude;

            float temp = 0;
            for (int channel = 0; channel < _nChannels; ++channel) {
                float* out = (float *)_outBufferListPtr->mBuffers[channel].mData + frameOffset;

                if (_playing) {
                    if (channel == 0) {
                        sp_noise_compute(_sp, _noise, nil, &temp);
                    }
                    *out = temp;
                } else {
                    *out = 0.0;
                }
            }
        }
    }
};

#endif
