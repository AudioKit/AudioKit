//
//  AKWhiteNoiseDSP.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#include "AKWhiteNoiseDSP.hpp"
#import "AKLinearParameterRamp.hpp"

extern "C" void* createWhiteNoiseDSP(int nChannels, double sampleRate) {
    AKWhiteNoiseDSP* dsp = new AKWhiteNoiseDSP();
    dsp->init(nChannels, sampleRate);
    return dsp;
}

struct AKWhiteNoiseDSP::_Internal {
    sp_noise *_noise;
    AKLinearParameterRamp amplitudeRamp;
};

AKWhiteNoiseDSP::AKWhiteNoiseDSP() : _private(new _Internal) {
    _private->amplitudeRamp.setTarget(defaultAmplitude, true);
    _private->amplitudeRamp.setDurationInSamples(defaultRampDurationSamples);
}

// Uses the ParameterAddress as a key
void AKWhiteNoiseDSP::setParameter(AUParameterAddress address, AUValue value, bool immediate) {
    switch (address) {
        case AKWhiteNoiseParameterAmplitude:
            _private->amplitudeRamp.setTarget(clamp(value, amplitudeLowerBound, amplitudeUpperBound), immediate);
            break;
        case AKWhiteNoiseParameterRampDuration:
            _private->amplitudeRamp.setRampDuration(value, _sampleRate);
            break;
    }
}

// Uses the ParameterAddress as a key
float AKWhiteNoiseDSP::getParameter(uint64_t address) {
    switch (address) {
        case AKWhiteNoiseParameterAmplitude:
            return _private->amplitudeRamp.getTarget();
        case AKWhiteNoiseParameterRampDuration:
            return _private->amplitudeRamp.getRampDuration(_sampleRate);
    }
    return 0;
}

void AKWhiteNoiseDSP::init(int _channels, double _sampleRate) {
    AKSoundpipeDSPBase::init(_channels, _sampleRate);
    sp_noise_create(&_private->_noise);
    sp_noise_init(_sp, _private->_noise);
    _private->_noise->amp = defaultAmplitude;
}

void AKWhiteNoiseDSP::destroy() {
    sp_noise_destroy(&_private->_noise);
    AKSoundpipeDSPBase::destroy();
}

void AKWhiteNoiseDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);

        // do ramping every 8 samples
        if ((frameOffset & 0x7) == 0) {
            _private->amplitudeRamp.advanceTo(_now + frameOffset);
        }

        _private->_noise->amp = _private->amplitudeRamp.getValue();

        float temp = 0;
        for (int channel = 0; channel < _nChannels; ++channel) {
            float* out = (float *)_outBufferListPtr->mBuffers[channel].mData + frameOffset;

            if (_playing) {
                if (channel == 0) {
                    sp_noise_compute(_sp, _private->_noise, nil, &temp);
                }
                *out = temp;
            } else {
                *out = 0.0;
            }
        }
    }
}
