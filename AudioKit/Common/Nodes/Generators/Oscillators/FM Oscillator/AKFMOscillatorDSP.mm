//
//  AKFMOscillatorDSP.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#include "AKFMOscillatorDSP.hpp"
#import "AKLinearParameterRamp.hpp"

extern "C" void* createFMOscillatorDSP(int nChannels, double sampleRate) {
    AKFMOscillatorDSP* dsp = new AKFMOscillatorDSP();
    dsp->init(nChannels, sampleRate);
    return dsp;
}

struct AKFMOscillatorDSP::_Internal {
    sp_fosc *_fosc;
    sp_ftbl *_ftbl;
    UInt32 _ftbl_size = 4096;
    AKLinearParameterRamp baseFrequencyRamp;
    AKLinearParameterRamp carrierMultiplierRamp;
    AKLinearParameterRamp modulatingMultiplierRamp;
    AKLinearParameterRamp modulationIndexRamp;
    AKLinearParameterRamp amplitudeRamp;
};

AKFMOscillatorDSP::AKFMOscillatorDSP() : _private(new _Internal) {
    _private->baseFrequencyRamp.setTarget(defaultBaseFrequency, true);
    _private->baseFrequencyRamp.setDurationInSamples(defaultRampDurationSamples);
    _private->carrierMultiplierRamp.setTarget(defaultCarrierMultiplier, true);
    _private->carrierMultiplierRamp.setDurationInSamples(defaultRampDurationSamples);
    _private->modulatingMultiplierRamp.setTarget(defaultModulatingMultiplier, true);
    _private->modulatingMultiplierRamp.setDurationInSamples(defaultRampDurationSamples);
    _private->modulationIndexRamp.setTarget(defaultModulationIndex, true);
    _private->modulationIndexRamp.setDurationInSamples(defaultRampDurationSamples);
    _private->amplitudeRamp.setTarget(defaultAmplitude, true);
    _private->amplitudeRamp.setDurationInSamples(defaultRampDurationSamples);
}

// Uses the ParameterAddress as a key
void AKFMOscillatorDSP::setParameter(AUParameterAddress address, AUValue value, bool immediate) {
    switch (address) {
        case AKFMOscillatorParameterBaseFrequency:
            _private->baseFrequencyRamp.setTarget(clamp(value, baseFrequencyLowerBound, baseFrequencyUpperBound), immediate);
            break;
        case AKFMOscillatorParameterCarrierMultiplier:
            _private->carrierMultiplierRamp.setTarget(clamp(value, carrierMultiplierLowerBound, carrierMultiplierUpperBound), immediate);
            break;
        case AKFMOscillatorParameterModulatingMultiplier:
            _private->modulatingMultiplierRamp.setTarget(clamp(value, modulatingMultiplierLowerBound, modulatingMultiplierUpperBound), immediate);
            break;
        case AKFMOscillatorParameterModulationIndex:
            _private->modulationIndexRamp.setTarget(clamp(value, modulationIndexLowerBound, modulationIndexUpperBound), immediate);
            break;
        case AKFMOscillatorParameterAmplitude:
            _private->amplitudeRamp.setTarget(clamp(value, amplitudeLowerBound, amplitudeUpperBound), immediate);
            break;
        case AKFMOscillatorParameterRampDuration:
            _private->baseFrequencyRamp.setRampDuration(value, _sampleRate);
            _private->carrierMultiplierRamp.setRampDuration(value, _sampleRate);
            _private->modulatingMultiplierRamp.setRampDuration(value, _sampleRate);
            _private->modulationIndexRamp.setRampDuration(value, _sampleRate);
            _private->amplitudeRamp.setRampDuration(value, _sampleRate);
            break;
    }
}

// Uses the ParameterAddress as a key
float AKFMOscillatorDSP::getParameter(uint64_t address) {
    switch (address) {
        case AKFMOscillatorParameterBaseFrequency:
            return _private->baseFrequencyRamp.getTarget();
        case AKFMOscillatorParameterCarrierMultiplier:
            return _private->carrierMultiplierRamp.getTarget();
        case AKFMOscillatorParameterModulatingMultiplier:
            return _private->modulatingMultiplierRamp.getTarget();
        case AKFMOscillatorParameterModulationIndex:
            return _private->modulationIndexRamp.getTarget();
        case AKFMOscillatorParameterAmplitude:
            return _private->amplitudeRamp.getTarget();
        case AKFMOscillatorParameterRampDuration:
            return _private->baseFrequencyRamp.getRampDuration(_sampleRate);
    }
    return 0;
}

void AKFMOscillatorDSP::init(int _channels, double _sampleRate) {
    AKSoundpipeDSPBase::init(_channels, _sampleRate);
    _playing = false;
    sp_fosc_create(&_private->_fosc);
    sp_fosc_init(_sp, _private->_fosc, _private->_ftbl);
    _private->_fosc->freq = defaultBaseFrequency;
    _private->_fosc->car = defaultCarrierMultiplier;
    _private->_fosc->mod = defaultModulatingMultiplier;
    _private->_fosc->indx = defaultModulationIndex;
    _private->_fosc->amp = defaultAmplitude;
}

void AKFMOscillatorDSP::destroy() {
    sp_fosc_destroy(&_private->_fosc);
    AKSoundpipeDSPBase::destroy();
}

void AKFMOscillatorDSP::setupWaveform(uint32_t size) {
    _private->_ftbl_size = size;
    sp_ftbl_create(_sp, &_private->_ftbl, _private->_ftbl_size);
}

void AKFMOscillatorDSP::setWaveformValue(uint32_t index, float value) {
    _private->_ftbl->tbl[index] = value;
}
void AKFMOscillatorDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);

        // do ramping every 8 samples
        if ((frameOffset & 0x7) == 0) {
            _private->baseFrequencyRamp.advanceTo(_now + frameOffset);
            _private->carrierMultiplierRamp.advanceTo(_now + frameOffset);
            _private->modulatingMultiplierRamp.advanceTo(_now + frameOffset);
            _private->modulationIndexRamp.advanceTo(_now + frameOffset);
            _private->amplitudeRamp.advanceTo(_now + frameOffset);
        }

        _private->_fosc->freq = _private->baseFrequencyRamp.getValue();
        _private->_fosc->car = _private->carrierMultiplierRamp.getValue();
        _private->_fosc->mod = _private->modulatingMultiplierRamp.getValue();
        _private->_fosc->indx = _private->modulationIndexRamp.getValue();
        _private->_fosc->amp = _private->amplitudeRamp.getValue();

        float temp = 0;
        for (int channel = 0; channel < _nChannels; ++channel) {
            float* out = (float *)_outBufferListPtr->mBuffers[channel].mData + frameOffset;

            if (_playing) {
                if (channel == 0) {
                    sp_fosc_compute(_sp, _private->_fosc, nil, &temp);
                }
                *out = temp;
            } else {
                *out = 0.0;
            }
        }
    }
}
