//
//  AKModalResonanceFilterDSP.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#include "AKModalResonanceFilterDSP.hpp"
#import "AKLinearParameterRamp.hpp"

extern "C" void* createModalResonanceFilterDSP(int nChannels, double sampleRate) {
    AKModalResonanceFilterDSP* dsp = new AKModalResonanceFilterDSP();
    dsp->init(nChannels, sampleRate);
    return dsp;
}

struct AKModalResonanceFilterDSP::_Internal {
    sp_mode *_mode0;
    sp_mode *_mode1;
    AKLinearParameterRamp frequencyRamp;
    AKLinearParameterRamp qualityFactorRamp;
};

AKModalResonanceFilterDSP::AKModalResonanceFilterDSP() : _private(new _Internal) {
    _private->frequencyRamp.setTarget(defaultFrequency, true);
    _private->frequencyRamp.setDurationInSamples(defaultRampDurationSamples);
    _private->qualityFactorRamp.setTarget(defaultQualityFactor, true);
    _private->qualityFactorRamp.setDurationInSamples(defaultRampDurationSamples);
}

// Uses the ParameterAddress as a key
void AKModalResonanceFilterDSP::setParameter(AUParameterAddress address, AUValue value, bool immediate) {
    switch (address) {
        case AKModalResonanceFilterParameterFrequency:
            _private->frequencyRamp.setTarget(clamp(value, frequencyLowerBound, frequencyUpperBound), immediate);
            break;
        case AKModalResonanceFilterParameterQualityFactor:
            _private->qualityFactorRamp.setTarget(clamp(value, qualityFactorLowerBound, qualityFactorUpperBound), immediate);
            break;
        case AKModalResonanceFilterParameterRampDuration:
            _private->frequencyRamp.setRampDuration(value, _sampleRate);
            _private->qualityFactorRamp.setRampDuration(value, _sampleRate);
            break;
    }
}

// Uses the ParameterAddress as a key
float AKModalResonanceFilterDSP::getParameter(uint64_t address) {
    switch (address) {
        case AKModalResonanceFilterParameterFrequency:
            return _private->frequencyRamp.getTarget();
        case AKModalResonanceFilterParameterQualityFactor:
            return _private->qualityFactorRamp.getTarget();
        case AKModalResonanceFilterParameterRampDuration:
            return _private->frequencyRamp.getRampDuration(_sampleRate);
    }
    return 0;
}

void AKModalResonanceFilterDSP::init(int _channels, double _sampleRate) {
    AKSoundpipeDSPBase::init(_channels, _sampleRate);
    sp_mode_create(&_private->_mode0);
    sp_mode_init(_sp, _private->_mode0);
    sp_mode_create(&_private->_mode1);
    sp_mode_init(_sp, _private->_mode1);
    _private->_mode0->freq = defaultFrequency;
    _private->_mode1->freq = defaultFrequency;
    _private->_mode0->q = defaultQualityFactor;
    _private->_mode1->q = defaultQualityFactor;
}

void AKModalResonanceFilterDSP::destroy() {
    sp_mode_destroy(&_private->_mode0);
    sp_mode_destroy(&_private->_mode1);
    AKSoundpipeDSPBase::destroy();
}

void AKModalResonanceFilterDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);

        // do ramping every 8 samples
        if ((frameOffset & 0x7) == 0) {
            _private->frequencyRamp.advanceTo(_now + frameOffset);
            _private->qualityFactorRamp.advanceTo(_now + frameOffset);
        }

        _private->_mode0->freq = _private->frequencyRamp.getValue();
        _private->_mode1->freq = _private->frequencyRamp.getValue();
        _private->_mode0->q = _private->qualityFactorRamp.getValue();
        _private->_mode1->q = _private->qualityFactorRamp.getValue();

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
                sp_mode_compute(_sp, _private->_mode0, in, out);
            } else {
                sp_mode_compute(_sp, _private->_mode1, in, out);
            }
        }
    }
}
