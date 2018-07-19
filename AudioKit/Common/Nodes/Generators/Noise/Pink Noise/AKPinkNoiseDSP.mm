//
//  AKPinkNoiseDSP.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#include "AKPinkNoiseDSP.hpp"
#import "AKLinearParameterRamp.hpp"

extern "C" void* createPinkNoiseDSP(int nChannels, double sampleRate) {
    AKPinkNoiseDSP* dsp = new AKPinkNoiseDSP();
    dsp->init(nChannels, sampleRate);
    return dsp;
}

struct AKPinkNoiseDSP::_Internal {
    sp_pinknoise *_pinknoise;
    AKLinearParameterRamp amplitudeRamp;
};

AKPinkNoiseDSP::AKPinkNoiseDSP() : _private(new _Internal) {
    _private->amplitudeRamp.setTarget(defaultAmplitude, true);
    _private->amplitudeRamp.setDurationInSamples(defaultRampDurationSamples);
}

// Uses the ParameterAddress as a key
void AKPinkNoiseDSP::setParameter(AUParameterAddress address, AUValue value, bool immediate) {
    switch (address) {
        case AKPinkNoiseParameterAmplitude:
            _private->amplitudeRamp.setTarget(clamp(value, amplitudeLowerBound, amplitudeUpperBound), immediate);
            break;
        case AKPinkNoiseParameterRampDuration:
            _private->amplitudeRamp.setRampDuration(value, _sampleRate);
            break;
    }
}

// Uses the ParameterAddress as a key
float AKPinkNoiseDSP::getParameter(uint64_t address) {
    switch (address) {
        case AKPinkNoiseParameterAmplitude:
            return _private->amplitudeRamp.getTarget();
        case AKPinkNoiseParameterRampDuration:
            return _private->amplitudeRamp.getRampDuration(_sampleRate);
    }
    return 0;
}

void AKPinkNoiseDSP::init(int _channels, double _sampleRate) {
    AKSoundpipeDSPBase::init(_channels, _sampleRate);
    sp_pinknoise_create(&_private->_pinknoise);
    sp_pinknoise_init(_sp, _private->_pinknoise);
    _private->_pinknoise->amp = defaultAmplitude;
}

void AKPinkNoiseDSP::destroy() {
    sp_pinknoise_destroy(&_private->_pinknoise);
    AKSoundpipeDSPBase::destroy();
}

void AKPinkNoiseDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);

        // do ramping every 8 samples
        if ((frameOffset & 0x7) == 0) {
            _private->amplitudeRamp.advanceTo(_now + frameOffset);
        }

        _private->_pinknoise->amp = _private->amplitudeRamp.getValue();

        float temp = 0;
        for (int channel = 0; channel < _nChannels; ++channel) {
            float* out = (float *)_outBufferListPtr->mBuffers[channel].mData + frameOffset;

            if (_playing) {
                if (channel == 0) {
                    sp_pinknoise_compute(_sp, _private->_pinknoise, nil, &temp);
                }
                *out = temp;
            } else {
                *out = 0.0;
            }
        }
    }
}
