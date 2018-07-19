//
//  AKMorphingOscillatorDSP.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#include "AKMorphingOscillatorDSP.hpp"
#import "AKLinearParameterRamp.hpp"

extern "C" void* createMorphingOscillatorDSP(int nChannels, double sampleRate) {
    AKMorphingOscillatorDSP* dsp = new AKMorphingOscillatorDSP();
    dsp->init(nChannels, sampleRate);
    return dsp;
}

struct AKMorphingOscillatorDSP::_Internal {
    sp_oscmorph *_oscmorph;
    sp_ftbl *_ft_array[4];
    UInt32 _ftbl_size = 4096;
    AKLinearParameterRamp frequencyRamp;
    AKLinearParameterRamp amplitudeRamp;
    AKLinearParameterRamp indexRamp;
    AKLinearParameterRamp detuningOffsetRamp;
    AKLinearParameterRamp detuningMultiplierRamp;
};

AKMorphingOscillatorDSP::AKMorphingOscillatorDSP() : _private(new _Internal) {
    _private->frequencyRamp.setTarget(defaultFrequency, true);
    _private->frequencyRamp.setDurationInSamples(defaultRampDurationSamples);
    _private->amplitudeRamp.setTarget(defaultAmplitude, true);
    _private->amplitudeRamp.setDurationInSamples(defaultRampDurationSamples);
    _private->indexRamp.setTarget(defaultIndex, true);
    _private->indexRamp.setDurationInSamples(defaultRampDurationSamples);
    _private->detuningOffsetRamp.setTarget(defaultDetuningOffset, true);
    _private->detuningOffsetRamp.setDurationInSamples(defaultRampDurationSamples);
    _private->detuningMultiplierRamp.setTarget(defaultDetuningMultiplier, true);
    _private->detuningMultiplierRamp.setDurationInSamples(defaultRampDurationSamples);
}

// Uses the ParameterAddress as a key
void AKMorphingOscillatorDSP::setParameter(AUParameterAddress address, AUValue value, bool immediate) {
    switch (address) {
        case AKMorphingOscillatorParameterFrequency:
            _private->frequencyRamp.setTarget(clamp(value, frequencyLowerBound, frequencyUpperBound), immediate);
            break;
        case AKMorphingOscillatorParameterAmplitude:
            _private->amplitudeRamp.setTarget(clamp(value, amplitudeLowerBound, amplitudeUpperBound), immediate);
            break;
        case AKMorphingOscillatorParameterIndex:
            _private->indexRamp.setTarget(clamp(value, indexLowerBound, indexUpperBound), immediate);
            break;
        case AKMorphingOscillatorParameterDetuningOffset:
            _private->detuningOffsetRamp.setTarget(clamp(value, detuningOffsetLowerBound, detuningOffsetUpperBound), immediate);
            break;
        case AKMorphingOscillatorParameterDetuningMultiplier:
            _private->detuningMultiplierRamp.setTarget(clamp(value, detuningMultiplierLowerBound, detuningMultiplierUpperBound), immediate);
            break;
        case AKMorphingOscillatorParameterRampDuration:
            _private->frequencyRamp.setRampDuration(value, _sampleRate);
            _private->amplitudeRamp.setRampDuration(value, _sampleRate);
            _private->indexRamp.setRampDuration(value, _sampleRate);
            _private->detuningOffsetRamp.setRampDuration(value, _sampleRate);
            _private->detuningMultiplierRamp.setRampDuration(value, _sampleRate);
            break;
    }
}

// Uses the ParameterAddress as a key
float AKMorphingOscillatorDSP::getParameter(uint64_t address) {
    switch (address) {
        case AKMorphingOscillatorParameterFrequency:
            return _private->frequencyRamp.getTarget();
        case AKMorphingOscillatorParameterAmplitude:
            return _private->amplitudeRamp.getTarget();
        case AKMorphingOscillatorParameterIndex:
            return _private->indexRamp.getTarget();
        case AKMorphingOscillatorParameterDetuningOffset:
            return _private->detuningOffsetRamp.getTarget();
        case AKMorphingOscillatorParameterDetuningMultiplier:
            return _private->detuningMultiplierRamp.getTarget();
        case AKMorphingOscillatorParameterRampDuration:
            return _private->frequencyRamp.getRampDuration(_sampleRate);
    }
    return 0;
}

void AKMorphingOscillatorDSP::init(int _channels, double _sampleRate) {
    AKSoundpipeDSPBase::init(_channels, _sampleRate);
    _playing = false;
    sp_oscmorph_create(&_private->_oscmorph);
}

void AKMorphingOscillatorDSP::destroy() {
    sp_oscmorph_destroy(&_private->_oscmorph);
    AKSoundpipeDSPBase::destroy();
}

void  AKMorphingOscillatorDSP::reset() {
    sp_oscmorph_init(_sp, _private->_oscmorph, _private->_ft_array, 4, 0);
    _private->_oscmorph->freq = defaultFrequency;
    _private->_oscmorph->amp = defaultAmplitude;
    _private->_oscmorph->wtpos = defaultIndex;
    AKSoundpipeDSPBase::reset();
}

void AKMorphingOscillatorDSP::setupIndividualWaveform(uint32_t waveform, uint32_t size) {
    _private->_ftbl_size = size;
    sp_ftbl_create(_sp, &_private->_ft_array[waveform], _private->_ftbl_size);
}

void AKMorphingOscillatorDSP::setIndividualWaveformValue(uint32_t waveform, uint32_t index, float value) {
    _private->_ft_array[waveform]->tbl[index] = value;
}
void AKMorphingOscillatorDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);

        // do ramping every 8 samples
        if ((frameOffset & 0x7) == 0) {
            _private->frequencyRamp.advanceTo(_now + frameOffset);
            _private->amplitudeRamp.advanceTo(_now + frameOffset);
            _private->indexRamp.advanceTo(_now + frameOffset);
            _private->detuningOffsetRamp.advanceTo(_now + frameOffset);
            _private->detuningMultiplierRamp.advanceTo(_now + frameOffset);
        }

        _private->_oscmorph->freq = _private->frequencyRamp.getValue() * _private->detuningMultiplierRamp.getValue() + _private->detuningOffsetRamp.getValue();
        _private->_oscmorph->amp = _private->amplitudeRamp.getValue();
        _private->_oscmorph->wtpos = _private->indexRamp.getValue();

        float temp = 0;
        for (int channel = 0; channel < _nChannels; ++channel) {
            float* out = (float *)_outBufferListPtr->mBuffers[channel].mData + frameOffset;

            if (_playing) {
                if (channel == 0) {
                    sp_oscmorph_compute(_sp, _private->_oscmorph, nil, &temp);
                }
                *out = temp;
            } else {
                *out = 0.0;
            }
        }
    }
}
