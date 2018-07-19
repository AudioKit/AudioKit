//
//  AKKorgLowPassFilterDSP.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#include "AKKorgLowPassFilterDSP.hpp"
#import "AKLinearParameterRamp.hpp"

extern "C" void* createKorgLowPassFilterDSP(int nChannels, double sampleRate) {
    AKKorgLowPassFilterDSP* dsp = new AKKorgLowPassFilterDSP();
    dsp->init(nChannels, sampleRate);
    return dsp;
}

struct AKKorgLowPassFilterDSP::_Internal {
    sp_wpkorg35 *_wpkorg350;
    sp_wpkorg35 *_wpkorg351;
    AKLinearParameterRamp cutoffFrequencyRamp;
    AKLinearParameterRamp resonanceRamp;
    AKLinearParameterRamp saturationRamp;
};

AKKorgLowPassFilterDSP::AKKorgLowPassFilterDSP() : _private(new _Internal) {
    _private->cutoffFrequencyRamp.setTarget(defaultCutoffFrequency, true);
    _private->cutoffFrequencyRamp.setDurationInSamples(defaultRampDurationSamples);
    _private->resonanceRamp.setTarget(defaultResonance, true);
    _private->resonanceRamp.setDurationInSamples(defaultRampDurationSamples);
    _private->saturationRamp.setTarget(defaultSaturation, true);
    _private->saturationRamp.setDurationInSamples(defaultRampDurationSamples);
}

// Uses the ParameterAddress as a key
void AKKorgLowPassFilterDSP::setParameter(AUParameterAddress address, AUValue value, bool immediate) {
    switch (address) {
        case AKKorgLowPassFilterParameterCutoffFrequency:
            _private->cutoffFrequencyRamp.setTarget(clamp(value, cutoffFrequencyLowerBound, cutoffFrequencyUpperBound), immediate);
            break;
        case AKKorgLowPassFilterParameterResonance:
            _private->resonanceRamp.setTarget(clamp(value, resonanceLowerBound, resonanceUpperBound), immediate);
            break;
        case AKKorgLowPassFilterParameterSaturation:
            _private->saturationRamp.setTarget(clamp(value, saturationLowerBound, saturationUpperBound), immediate);
            break;
        case AKKorgLowPassFilterParameterRampDuration:
            _private->cutoffFrequencyRamp.setRampDuration(value, _sampleRate);
            _private->resonanceRamp.setRampDuration(value, _sampleRate);
            _private->saturationRamp.setRampDuration(value, _sampleRate);
            break;
    }
}

// Uses the ParameterAddress as a key
float AKKorgLowPassFilterDSP::getParameter(uint64_t address) {
    switch (address) {
        case AKKorgLowPassFilterParameterCutoffFrequency:
            return _private->cutoffFrequencyRamp.getTarget();
        case AKKorgLowPassFilterParameterResonance:
            return _private->resonanceRamp.getTarget();
        case AKKorgLowPassFilterParameterSaturation:
            return _private->saturationRamp.getTarget();
        case AKKorgLowPassFilterParameterRampDuration:
            return _private->cutoffFrequencyRamp.getRampDuration(_sampleRate);
    }
    return 0;
}

void AKKorgLowPassFilterDSP::init(int _channels, double _sampleRate) {
    AKSoundpipeDSPBase::init(_channels, _sampleRate);
    sp_wpkorg35_create(&_private->_wpkorg350);
    sp_wpkorg35_init(_sp, _private->_wpkorg350);
    sp_wpkorg35_create(&_private->_wpkorg351);
    sp_wpkorg35_init(_sp, _private->_wpkorg351);
    _private->_wpkorg350->cutoff = defaultCutoffFrequency;
    _private->_wpkorg351->cutoff = defaultCutoffFrequency;
    _private->_wpkorg350->res = defaultResonance;
    _private->_wpkorg351->res = defaultResonance;
    _private->_wpkorg350->saturation = defaultSaturation;
    _private->_wpkorg351->saturation = defaultSaturation;
}

void AKKorgLowPassFilterDSP::destroy() {
    sp_wpkorg35_destroy(&_private->_wpkorg350);
    sp_wpkorg35_destroy(&_private->_wpkorg351);
    AKSoundpipeDSPBase::destroy();
}

void AKKorgLowPassFilterDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);

        // do ramping every 8 samples
        if ((frameOffset & 0x7) == 0) {
            _private->cutoffFrequencyRamp.advanceTo(_now + frameOffset);
            _private->resonanceRamp.advanceTo(_now + frameOffset);
            _private->saturationRamp.advanceTo(_now + frameOffset);
        }

        _private->_wpkorg350->cutoff = _private->cutoffFrequencyRamp.getValue() - 0.0001;
        _private->_wpkorg351->cutoff = _private->cutoffFrequencyRamp.getValue() - 0.0001;
        _private->_wpkorg350->res = _private->resonanceRamp.getValue();
        _private->_wpkorg351->res = _private->resonanceRamp.getValue();
        _private->_wpkorg350->saturation = _private->saturationRamp.getValue();
        _private->_wpkorg351->saturation = _private->saturationRamp.getValue();

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
                sp_wpkorg35_compute(_sp, _private->_wpkorg350, in, out);
            } else {
                sp_wpkorg35_compute(_sp, _private->_wpkorg351, in, out);
            }
        }
    }
}
