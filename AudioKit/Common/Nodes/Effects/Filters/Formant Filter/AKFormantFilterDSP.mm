//
//  AKFormantFilterDSP.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#include "AKFormantFilterDSP.hpp"
#import "AKLinearParameterRamp.hpp"

extern "C" void* createFormantFilterDSP(int nChannels, double sampleRate) {
    AKFormantFilterDSP* dsp = new AKFormantFilterDSP();
    dsp->init(nChannels, sampleRate);
    return dsp;
}

struct AKFormantFilterDSP::_Internal {
    sp_fofilt *_fofilt0;
    sp_fofilt *_fofilt1;
    AKLinearParameterRamp centerFrequencyRamp;
    AKLinearParameterRamp attackDurationRamp;
    AKLinearParameterRamp decayDurationRamp;
};

AKFormantFilterDSP::AKFormantFilterDSP() : _private(new _Internal) {
    _private->centerFrequencyRamp.setTarget(defaultCenterFrequency, true);
    _private->centerFrequencyRamp.setDurationInSamples(defaultRampDurationSamples);
    _private->attackDurationRamp.setTarget(defaultAttackDuration, true);
    _private->attackDurationRamp.setDurationInSamples(defaultRampDurationSamples);
    _private->decayDurationRamp.setTarget(defaultDecayDuration, true);
    _private->decayDurationRamp.setDurationInSamples(defaultRampDurationSamples);
}

// Uses the ParameterAddress as a key
void AKFormantFilterDSP::setParameter(AUParameterAddress address, AUValue value, bool immediate) {
    switch (address) {
        case AKFormantFilterParameterCenterFrequency:
            _private->centerFrequencyRamp.setTarget(clamp(value, centerFrequencyLowerBound, centerFrequencyUpperBound), immediate);
            break;
        case AKFormantFilterParameterAttackDuration:
            _private->attackDurationRamp.setTarget(clamp(value, attackDurationLowerBound, attackDurationUpperBound), immediate);
            break;
        case AKFormantFilterParameterDecayDuration:
            _private->decayDurationRamp.setTarget(clamp(value, decayDurationLowerBound, decayDurationUpperBound), immediate);
            break;
        case AKFormantFilterParameterRampDuration:
            _private->centerFrequencyRamp.setRampDuration(value, _sampleRate);
            _private->attackDurationRamp.setRampDuration(value, _sampleRate);
            _private->decayDurationRamp.setRampDuration(value, _sampleRate);
            break;
    }
}

// Uses the ParameterAddress as a key
float AKFormantFilterDSP::getParameter(uint64_t address) {
    switch (address) {
        case AKFormantFilterParameterCenterFrequency:
            return _private->centerFrequencyRamp.getTarget();
        case AKFormantFilterParameterAttackDuration:
            return _private->attackDurationRamp.getTarget();
        case AKFormantFilterParameterDecayDuration:
            return _private->decayDurationRamp.getTarget();
        case AKFormantFilterParameterRampDuration:
            return _private->centerFrequencyRamp.getRampDuration(_sampleRate);
    }
    return 0;
}

void AKFormantFilterDSP::init(int _channels, double _sampleRate) {
    AKSoundpipeDSPBase::init(_channels, _sampleRate);
    sp_fofilt_create(&_private->_fofilt0);
    sp_fofilt_init(_sp, _private->_fofilt0);
    sp_fofilt_create(&_private->_fofilt1);
    sp_fofilt_init(_sp, _private->_fofilt1);
    _private->_fofilt0->freq = defaultCenterFrequency;
    _private->_fofilt1->freq = defaultCenterFrequency;
    _private->_fofilt0->atk = defaultAttackDuration;
    _private->_fofilt1->atk = defaultAttackDuration;
    _private->_fofilt0->dec = defaultDecayDuration;
    _private->_fofilt1->dec = defaultDecayDuration;
}

void AKFormantFilterDSP::destroy() {
    sp_fofilt_destroy(&_private->_fofilt0);
    sp_fofilt_destroy(&_private->_fofilt1);
    AKSoundpipeDSPBase::destroy();
}

void AKFormantFilterDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);

        // do ramping every 8 samples
        if ((frameOffset & 0x7) == 0) {
            _private->centerFrequencyRamp.advanceTo(_now + frameOffset);
            _private->attackDurationRamp.advanceTo(_now + frameOffset);
            _private->decayDurationRamp.advanceTo(_now + frameOffset);
        }

        _private->_fofilt0->freq = _private->centerFrequencyRamp.getValue();
        _private->_fofilt1->freq = _private->centerFrequencyRamp.getValue();
        _private->_fofilt0->atk = _private->attackDurationRamp.getValue();
        _private->_fofilt1->atk = _private->attackDurationRamp.getValue();
        _private->_fofilt0->dec = _private->decayDurationRamp.getValue();
        _private->_fofilt1->dec = _private->decayDurationRamp.getValue();

        float *tmpin[2];
        float *tmpout[2];
        for (int channel = 0; channel < _nChannels; ++channel) {
            float* in  = (float *)_inBufferListPtr->mBuffers[channel].mData  + frameOffset;
            float* out = (float *)_outBufferListPtr->mBuffers[channel].mData + frameOffset;
            if (channel < 2) {
                tmpin[channel] = in;
                tmpout[channel] = out;
            }
            if (!_playing) {
                *out = *in;
                continue;
            }

            if (channel == 0) {
                sp_fofilt_compute(_sp, _private->_fofilt0, in, out);
            } else {
                sp_fofilt_compute(_sp, _private->_fofilt1, in, out);
            }
        }
    }
}
