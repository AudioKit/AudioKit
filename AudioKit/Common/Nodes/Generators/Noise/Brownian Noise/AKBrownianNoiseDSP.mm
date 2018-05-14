//
//  AKBrownianNoiseDSP.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#include "AKBrownianNoiseDSP.hpp"
#import "AKLinearParameterRamp.hpp"

extern "C" void* createBrownianNoiseDSP(int nChannels, double sampleRate) {
    AKBrownianNoiseDSP* dsp = new AKBrownianNoiseDSP();
    dsp->init(nChannels, sampleRate);
    return dsp;
}

struct AKBrownianNoiseDSP::_Internal {
    sp_brown *_brown;
    AKLinearParameterRamp amplitudeRamp;
};

AKBrownianNoiseDSP::AKBrownianNoiseDSP() : _private(new _Internal) {
    _private->amplitudeRamp.setTarget(defaultAmplitude, true);
    _private->amplitudeRamp.setDurationInSamples(defaultRampDurationSamples);
}

// Uses the ParameterAddress as a key
void AKBrownianNoiseDSP::setParameter(AUParameterAddress address, AUValue value, bool immediate) {
    switch (address) {
        case AKBrownianNoiseParameterAmplitude:
            _private->amplitudeRamp.setTarget(clamp(value, amplitudeLowerBound, amplitudeUpperBound), immediate);
            break;
        case AKBrownianNoiseParameterRampDuration:
            _private->amplitudeRamp.setRampDuration(value, _sampleRate);
            break;
    }
}

// Uses the ParameterAddress as a key
float AKBrownianNoiseDSP::getParameter(uint64_t address) {
    switch (address) {
        case AKBrownianNoiseParameterAmplitude:
            return _private->amplitudeRamp.getTarget();
        case AKBrownianNoiseParameterRampDuration:
            return _private->amplitudeRamp.getRampDuration(_sampleRate);
    }
    return 0;
}

void AKBrownianNoiseDSP::init(int _channels, double _sampleRate) {
    AKSoundpipeDSPBase::init(_channels, _sampleRate);
    sp_brown_create(&_private->_brown);
    sp_brown_init(_sp, _private->_brown);
}

void AKBrownianNoiseDSP::destroy() {
    sp_brown_destroy(&_private->_brown);
    AKSoundpipeDSPBase::destroy();
}

void AKBrownianNoiseDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);

        // do ramping every 8 samples
        if ((frameOffset & 0x7) == 0) {
            _private->amplitudeRamp.advanceTo(_now + frameOffset);
        }

        float temp = 0;
        for (int channel = 0; channel < _nChannels; ++channel) {
            float* out = (float *)_outBufferListPtr->mBuffers[channel].mData + frameOffset;

            if (_playing) {
                if (channel == 0) {
                    sp_brown_compute(_sp, _private->_brown, nil, &temp);
                }
                *out = temp * _private->amplitudeRamp.getValue();
            } else {
                *out = 0.0;
            }
        }
    }
}
