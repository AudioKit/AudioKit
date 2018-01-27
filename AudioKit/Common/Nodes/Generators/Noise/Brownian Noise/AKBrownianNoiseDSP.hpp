//
//  AKBrownianNoiseDSP.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once

#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(AUParameterAddress, AKBrownianNoiseParameter) {
    AKBrownianNoiseParameterAmplitude,
    AKBrownianNoiseParameterRampTime
};

#import "AKLinearParameterRamp.hpp"  // have to put this here to get it included in umbrella header

#ifndef __cplusplus

void* createBrownianNoiseDSP(int nChannels, double sampleRate);

#else

#import "AKSoundpipeDSPBase.hpp"

class AKBrownianNoiseDSP : public AKSoundpipeDSPBase {

    sp_brown *_brown;

private:
    AKLinearParameterRamp amplitudeRamp;

public:
    AKBrownianNoiseDSP() {
        amplitudeRamp.setTarget(1, true);
        amplitudeRamp.setDurationInSamples(10000);
    }

    /** Uses the ParameterAddress as a key */
    void setParameter(AUParameterAddress address, float value, bool immediate) override {
        switch (address) {
            case AKBrownianNoiseParameterAmplitude:
                amplitudeRamp.setTarget(value, immediate);
                break;
            case AKBrownianNoiseParameterRampTime:
                amplitudeRamp.setRampTime(value, _sampleRate);
                break;
        }
    }

    /** Uses the ParameterAddress as a key */
    float getParameter(AUParameterAddress address) override {
        switch (address) {
            case AKBrownianNoiseParameterAmplitude:
                return amplitudeRamp.getTarget();
            case AKBrownianNoiseParameterRampTime:
                return amplitudeRamp.getRampTime(_sampleRate);
        }
        return 0;
    }

    void init(int _channels, double _sampleRate) override {
        AKSoundpipeDSPBase::init(_channels, _sampleRate);

        sp_brown_create(&_brown);
        sp_brown_init(_sp, _brown);
    }

    void destroy() {
        sp_brown_destroy(&_brown);
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
            float temp = 0;
            for (int channel = 0; channel < _nChannels; ++channel) {
                float* out = (float *)_outBufferListPtr->mBuffers[channel].mData + frameOffset;

                if (_playing) {
                    if (channel == 0) {
                        sp_brown_compute(_sp, _brown, nil, &temp);
                    }
                    *out = temp * amplitude;
                } else {
                    *out = 0.0;
                }
            }
        }
    }
};

#endif
