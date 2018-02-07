//
//  AKPinkNoiseDSP.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once

#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(AUParameterAddress, AKPinkNoiseParameter) {
    AKPinkNoiseParameterAmplitude,
    AKPinkNoiseParameterRampTime
};

#import "AKLinearParameterRamp.hpp"  // have to put this here to get it included in umbrella header

#ifndef __cplusplus

void* createPinkNoiseDSP(int nChannels, double sampleRate);

#else

#import "AKSoundpipeDSPBase.hpp"

class AKPinkNoiseDSP : public AKSoundpipeDSPBase {

    sp_pinknoise *_pinknoise;

private:
    AKLinearParameterRamp amplitudeRamp;

public:
    AKPinkNoiseDSP() {
        amplitudeRamp.setTarget(1, true);
        amplitudeRamp.setDurationInSamples(10000);
    }

    /** Uses the ParameterAddress as a key */
    void setParameter(AUParameterAddress address, float value, bool immediate) override {
        switch (address) {
            case AKPinkNoiseParameterAmplitude:
                amplitudeRamp.setTarget(value, immediate);
                break;
            case AKPinkNoiseParameterRampTime:
                amplitudeRamp.setRampTime(value, _sampleRate);
                break;
        }
    }

    /** Uses the ParameterAddress as a key */
    float getParameter(AUParameterAddress address) override {
        switch (address) {
            case AKPinkNoiseParameterAmplitude:
                return amplitudeRamp.getTarget();
            case AKPinkNoiseParameterRampTime:
                return amplitudeRamp.getRampTime(_sampleRate);
        }
        return 0;
    }

    void init(int _channels, double _sampleRate) override {
        AKSoundpipeDSPBase::init(_channels, _sampleRate);

        sp_pinknoise_create(&_pinknoise);
        sp_pinknoise_init(_sp, _pinknoise);
        _pinknoise->amp = 1;
    }

    void destroy() {
        sp_pinknoise_destroy(&_pinknoise);
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
            _pinknoise->amp = amplitude;

            float temp = 0;
            for (int channel = 0; channel < _nChannels; ++channel) {
                float* out = (float *)_outBufferListPtr->mBuffers[channel].mData + frameOffset;

                if (_playing) {
                    if (channel == 0) {
                        sp_pinknoise_compute(_sp, _pinknoise, nil, &temp);
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
