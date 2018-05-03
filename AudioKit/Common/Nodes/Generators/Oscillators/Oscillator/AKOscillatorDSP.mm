//
//  AKOscillatorDSP.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#include "AKOscillatorDSP.hpp"
#import "AKLinearParameterRamp.hpp"

extern "C" void* createOscillatorDSP(int nChannels, double sampleRate) {
    AKOscillatorDSP* dsp = new AKOscillatorDSP();
    dsp->init(nChannels, sampleRate);
    return dsp;
}

struct AKOscillatorDSP::_Internal {
    sp_osc *_osc;
    sp_ftbl *_ftbl;
    UInt32 _ftbl_size = 4096;
    AKLinearParameterRamp frequencyRamp;
    AKLinearParameterRamp amplitudeRamp;
    AKLinearParameterRamp detuningOffsetRamp;
    AKLinearParameterRamp detuningMultiplierRamp;
};

AKOscillatorDSP::AKOscillatorDSP() : _private(new _Internal) {
    _private->frequencyRamp.setTarget(defaultFrequency, true);
    _private->frequencyRamp.setDurationInSamples(defaultRampDurationSamples);
    _private->amplitudeRamp.setTarget(defaultAmplitude, true);
    _private->amplitudeRamp.setDurationInSamples(defaultRampDurationSamples);
    _private->detuningOffsetRamp.setTarget(defaultDetuningOffset, true);
    _private->detuningOffsetRamp.setDurationInSamples(defaultRampDurationSamples);
    _private->detuningMultiplierRamp.setTarget(defaultDetuningMultiplier, true);
    _private->detuningMultiplierRamp.setDurationInSamples(defaultRampDurationSamples);
}

// Uses the ParameterAddress as a key
void AKOscillatorDSP::setParameter(AUParameterAddress address, AUValue value, bool immediate) {
    switch (address) {
        case AKOscillatorParameterFrequency:
            _private->frequencyRamp.setTarget(clamp(value, frequencyLowerBound, frequencyUpperBound), immediate);
            break;
        case AKOscillatorParameterAmplitude:
            _private->amplitudeRamp.setTarget(clamp(value, amplitudeLowerBound, amplitudeUpperBound), immediate);
            break;
        case AKOscillatorParameterDetuningOffset:
            _private->detuningOffsetRamp.setTarget(clamp(value, detuningOffsetLowerBound, detuningOffsetUpperBound), immediate);
            break;
        case AKOscillatorParameterDetuningMultiplier:
            _private->detuningMultiplierRamp.setTarget(clamp(value, detuningMultiplierLowerBound, detuningMultiplierUpperBound), immediate);
            break;
        case AKOscillatorParameterRampDuration:
            _private->frequencyRamp.setRampDuration(value, _sampleRate);
            _private->amplitudeRamp.setRampDuration(value, _sampleRate);
            _private->detuningOffsetRamp.setRampDuration(value, _sampleRate);
            _private->detuningMultiplierRamp.setRampDuration(value, _sampleRate);
            break;
    }
}

// Uses the ParameterAddress as a key
float AKOscillatorDSP::getParameter(uint64_t address) {
    switch (address) {
        case AKOscillatorParameterFrequency:
            return _private->frequencyRamp.getTarget();
        case AKOscillatorParameterAmplitude:
            return _private->amplitudeRamp.getTarget();
        case AKOscillatorParameterDetuningOffset:
            return _private->detuningOffsetRamp.getTarget();
        case AKOscillatorParameterDetuningMultiplier:
            return _private->detuningMultiplierRamp.getTarget();
        case AKOscillatorParameterRampDuration:
            return _private->frequencyRamp.getRampDuration(_sampleRate);
    }
    return 0;
}

void AKOscillatorDSP::init(int _channels, double _sampleRate) {
    AKSoundpipeDSPBase::init(_channels, _sampleRate);
    _playing = false;
    sp_osc_create(&_private->_osc);
    sp_osc_init(_sp, _private->_osc, _private->_ftbl, 0);
    _private->_osc->freq = defaultFrequency;
    _private->_osc->amp = defaultAmplitude;
}

void AKOscillatorDSP::destroy() {
    sp_osc_destroy(&_private->_osc);
    AKSoundpipeDSPBase::destroy();
}

void AKOscillatorDSP::setupWaveform(uint32_t size) {
    _private->_ftbl_size = size;
    sp_ftbl_create(_sp, &_private->_ftbl, _private->_ftbl_size);
}

void AKOscillatorDSP::setWaveformValue(uint32_t index, float value) {
    _private->_ftbl->tbl[index] = value;
}

void AKOscillatorDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);

        // do ramping every 8 samples
        if ((frameOffset & 0x7) == 0) {
            _private->frequencyRamp.advanceTo(_now + frameOffset);
            _private->amplitudeRamp.advanceTo(_now + frameOffset);
            _private->detuningOffsetRamp.advanceTo(_now + frameOffset);
            _private->detuningMultiplierRamp.advanceTo(_now + frameOffset);
        }
        _private->_osc->freq = _private->frequencyRamp.getValue() * _private->detuningMultiplierRamp.getValue() + _private->detuningOffsetRamp.getValue();
        _private->_osc->amp = _private->amplitudeRamp.getValue();

        float temp = 0;
        for (int channel = 0; channel < _nChannels; ++channel) {
            float* out = (float *)_outBufferListPtr->mBuffers[channel].mData + frameOffset;

            if (_playing) {
                if (channel == 0) {
                    sp_osc_compute(_sp, _private->_osc, nil, &temp);
                }
                *out = temp;
            } else {
                *out = 0.0;
            }
        }
    }
}
