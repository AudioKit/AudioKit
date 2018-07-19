//
//  AKDripDSP.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#include "AKDripDSP.hpp"
#import "AKLinearParameterRamp.hpp"

extern "C" void* createDripDSP(int nChannels, double sampleRate) {
    AKDripDSP* dsp = new AKDripDSP();
    dsp->init(nChannels, sampleRate);
    return dsp;
}

struct AKDripDSP::_Internal {
    sp_drip *_drip;
    AKLinearParameterRamp intensityRamp;
    AKLinearParameterRamp dampingFactorRamp;
    AKLinearParameterRamp energyReturnRamp;
    AKLinearParameterRamp mainResonantFrequencyRamp;
    AKLinearParameterRamp firstResonantFrequencyRamp;
    AKLinearParameterRamp secondResonantFrequencyRamp;
    AKLinearParameterRamp amplitudeRamp;
};

AKDripDSP::AKDripDSP() : _private(new _Internal) {
    _private->intensityRamp.setTarget(defaultIntensity, true);
    _private->intensityRamp.setDurationInSamples(defaultRampDurationSamples);
    _private->dampingFactorRamp.setTarget(defaultDampingFactor, true);
    _private->dampingFactorRamp.setDurationInSamples(defaultRampDurationSamples);
    _private->energyReturnRamp.setTarget(defaultEnergyReturn, true);
    _private->energyReturnRamp.setDurationInSamples(defaultRampDurationSamples);
    _private->mainResonantFrequencyRamp.setTarget(defaultMainResonantFrequency, true);
    _private->mainResonantFrequencyRamp.setDurationInSamples(defaultRampDurationSamples);
    _private->firstResonantFrequencyRamp.setTarget(defaultFirstResonantFrequency, true);
    _private->firstResonantFrequencyRamp.setDurationInSamples(defaultRampDurationSamples);
    _private->secondResonantFrequencyRamp.setTarget(defaultSecondResonantFrequency, true);
    _private->secondResonantFrequencyRamp.setDurationInSamples(defaultRampDurationSamples);
    _private->amplitudeRamp.setTarget(defaultAmplitude, true);
    _private->amplitudeRamp.setDurationInSamples(defaultRampDurationSamples);
}

// Uses the ParameterAddress as a key
void AKDripDSP::setParameter(AUParameterAddress address, AUValue value, bool immediate) {
    switch (address) {
        case AKDripParameterIntensity:
            _private->intensityRamp.setTarget(clamp(value, intensityLowerBound, intensityUpperBound), immediate);
            break;
        case AKDripParameterDampingFactor:
            _private->dampingFactorRamp.setTarget(clamp(value, dampingFactorLowerBound, dampingFactorUpperBound), immediate);
            break;
        case AKDripParameterEnergyReturn:
            _private->energyReturnRamp.setTarget(clamp(value, energyReturnLowerBound, energyReturnUpperBound), immediate);
            break;
        case AKDripParameterMainResonantFrequency:
            _private->mainResonantFrequencyRamp.setTarget(clamp(value, mainResonantFrequencyLowerBound, mainResonantFrequencyUpperBound), immediate);
            break;
        case AKDripParameterFirstResonantFrequency:
            _private->firstResonantFrequencyRamp.setTarget(clamp(value, firstResonantFrequencyLowerBound, firstResonantFrequencyUpperBound), immediate);
            break;
        case AKDripParameterSecondResonantFrequency:
            _private->secondResonantFrequencyRamp.setTarget(clamp(value, secondResonantFrequencyLowerBound, secondResonantFrequencyUpperBound), immediate);
            break;
        case AKDripParameterAmplitude:
            _private->amplitudeRamp.setTarget(clamp(value, amplitudeLowerBound, amplitudeUpperBound), immediate);
            break;
        case AKDripParameterRampDuration:
            _private->intensityRamp.setRampDuration(value, _sampleRate);
            _private->dampingFactorRamp.setRampDuration(value, _sampleRate);
            _private->energyReturnRamp.setRampDuration(value, _sampleRate);
            _private->mainResonantFrequencyRamp.setRampDuration(value, _sampleRate);
            _private->firstResonantFrequencyRamp.setRampDuration(value, _sampleRate);
            _private->secondResonantFrequencyRamp.setRampDuration(value, _sampleRate);
            _private->amplitudeRamp.setRampDuration(value, _sampleRate);
            break;
    }
}

// Uses the ParameterAddress as a key
float AKDripDSP::getParameter(uint64_t address) {
    switch (address) {
        case AKDripParameterIntensity:
            return _private->intensityRamp.getTarget();
        case AKDripParameterDampingFactor:
            return _private->dampingFactorRamp.getTarget();
        case AKDripParameterEnergyReturn:
            return _private->energyReturnRamp.getTarget();
        case AKDripParameterMainResonantFrequency:
            return _private->mainResonantFrequencyRamp.getTarget();
        case AKDripParameterFirstResonantFrequency:
            return _private->firstResonantFrequencyRamp.getTarget();
        case AKDripParameterSecondResonantFrequency:
            return _private->secondResonantFrequencyRamp.getTarget();
        case AKDripParameterAmplitude:
            return _private->amplitudeRamp.getTarget();
        case AKDripParameterRampDuration:
            return _private->intensityRamp.getRampDuration(_sampleRate);
    }
    return 0;
}

void AKDripDSP::init(int _channels, double _sampleRate) {
    AKSoundpipeDSPBase::init(_channels, _sampleRate);
    sp_drip_create(&_private->_drip);
    sp_drip_init(_sp, _private->_drip, 0.9);
    _private->_drip->num_tubes = defaultIntensity;
    _private->_drip->damp = defaultDampingFactor;
    _private->_drip->shake_max = defaultEnergyReturn;
    _private->_drip->freq = defaultMainResonantFrequency;
    _private->_drip->freq1 = defaultFirstResonantFrequency;
    _private->_drip->freq2 = defaultSecondResonantFrequency;
    _private->_drip->amp = defaultAmplitude;
}

void AKDripDSP::destroy() {
    sp_drip_destroy(&_private->_drip);
    AKSoundpipeDSPBase::destroy();
}

void AKDripDSP::trigger() {
    internalTrigger = 1;
}

void AKDripDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);

        // do ramping every 8 samples
        if ((frameOffset & 0x7) == 0) {
            _private->intensityRamp.advanceTo(_now + frameOffset);
            _private->dampingFactorRamp.advanceTo(_now + frameOffset);
            _private->energyReturnRamp.advanceTo(_now + frameOffset);
            _private->mainResonantFrequencyRamp.advanceTo(_now + frameOffset);
            _private->firstResonantFrequencyRamp.advanceTo(_now + frameOffset);
            _private->secondResonantFrequencyRamp.advanceTo(_now + frameOffset);
            _private->amplitudeRamp.advanceTo(_now + frameOffset);
        }

        _private->_drip->num_tubes = _private->intensityRamp.getValue();
        _private->_drip->damp = _private->dampingFactorRamp.getValue();
        _private->_drip->shake_max = _private->energyReturnRamp.getValue();
        _private->_drip->freq = _private->mainResonantFrequencyRamp.getValue();
        _private->_drip->freq1 = _private->firstResonantFrequencyRamp.getValue();
        _private->_drip->freq2 = _private->secondResonantFrequencyRamp.getValue();
        _private->_drip->amp = _private->amplitudeRamp.getValue();

        float temp = 0;
        for (int channel = 0; channel < _nChannels; ++channel) {
            float* out = (float *)_outBufferListPtr->mBuffers[channel].mData + frameOffset;

            if (_playing) {
                if (channel == 0) {
                    sp_drip_compute(_sp, _private->_drip, &internalTrigger, &temp);
                }
                *out = temp;
            } else {
                *out = 0.0;
            }
        }
    }
}
