//
//  AKEqualizerFilterDSP.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#include "AKEqualizerFilterDSP.hpp"
#import "AKLinearParameterRamp.hpp"

extern "C" void* createEqualizerFilterDSP(int nChannels, double sampleRate) {
    AKEqualizerFilterDSP* dsp = new AKEqualizerFilterDSP();
    dsp->init(nChannels, sampleRate);
    return dsp;
}

struct AKEqualizerFilterDSP::_Internal {
    sp_eqfil *_eqfil0;
    sp_eqfil *_eqfil1;
    AKLinearParameterRamp centerFrequencyRamp;
    AKLinearParameterRamp bandwidthRamp;
    AKLinearParameterRamp gainRamp;
};

AKEqualizerFilterDSP::AKEqualizerFilterDSP() : _private(new _Internal) {
    _private->centerFrequencyRamp.setTarget(defaultCenterFrequency, true);
    _private->centerFrequencyRamp.setDurationInSamples(defaultRampDurationSamples);
    _private->bandwidthRamp.setTarget(defaultBandwidth, true);
    _private->bandwidthRamp.setDurationInSamples(defaultRampDurationSamples);
    _private->gainRamp.setTarget(defaultGain, true);
    _private->gainRamp.setDurationInSamples(defaultRampDurationSamples);
}

// Uses the ParameterAddress as a key
void AKEqualizerFilterDSP::setParameter(AUParameterAddress address, AUValue value, bool immediate) {
    switch (address) {
        case AKEqualizerFilterParameterCenterFrequency:
            _private->centerFrequencyRamp.setTarget(clamp(value, centerFrequencyLowerBound, centerFrequencyUpperBound), immediate);
            break;
        case AKEqualizerFilterParameterBandwidth:
            _private->bandwidthRamp.setTarget(clamp(value, bandwidthLowerBound, bandwidthUpperBound), immediate);
            break;
        case AKEqualizerFilterParameterGain:
            _private->gainRamp.setTarget(clamp(value, gainLowerBound, gainUpperBound), immediate);
            break;
        case AKEqualizerFilterParameterRampDuration:
            _private->centerFrequencyRamp.setRampDuration(value, _sampleRate);
            _private->bandwidthRamp.setRampDuration(value, _sampleRate);
            _private->gainRamp.setRampDuration(value, _sampleRate);
            break;
    }
}

// Uses the ParameterAddress as a key
float AKEqualizerFilterDSP::getParameter(uint64_t address) {
    switch (address) {
        case AKEqualizerFilterParameterCenterFrequency:
            return _private->centerFrequencyRamp.getTarget();
        case AKEqualizerFilterParameterBandwidth:
            return _private->bandwidthRamp.getTarget();
        case AKEqualizerFilterParameterGain:
            return _private->gainRamp.getTarget();
        case AKEqualizerFilterParameterRampDuration:
            return _private->centerFrequencyRamp.getRampDuration(_sampleRate);
    }
    return 0;
}

void AKEqualizerFilterDSP::init(int _channels, double _sampleRate) {
    AKSoundpipeDSPBase::init(_channels, _sampleRate);
    sp_eqfil_create(&_private->_eqfil0);
    sp_eqfil_init(_sp, _private->_eqfil0);
    sp_eqfil_create(&_private->_eqfil1);
    sp_eqfil_init(_sp, _private->_eqfil1);
    _private->_eqfil0->freq = defaultCenterFrequency;
    _private->_eqfil1->freq = defaultCenterFrequency;
    _private->_eqfil0->bw = defaultBandwidth;
    _private->_eqfil1->bw = defaultBandwidth;
    _private->_eqfil0->gain = defaultGain;
    _private->_eqfil1->gain = defaultGain;
}

void AKEqualizerFilterDSP::destroy() {
    sp_eqfil_destroy(&_private->_eqfil0);
    sp_eqfil_destroy(&_private->_eqfil1);
    AKSoundpipeDSPBase::destroy();
}

void AKEqualizerFilterDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);

        // do ramping every 8 samples
        if ((frameOffset & 0x7) == 0) {
            _private->centerFrequencyRamp.advanceTo(_now + frameOffset);
            _private->bandwidthRamp.advanceTo(_now + frameOffset);
            _private->gainRamp.advanceTo(_now + frameOffset);
        }

        _private->_eqfil0->freq = _private->centerFrequencyRamp.getValue();
        _private->_eqfil1->freq = _private->centerFrequencyRamp.getValue();
        _private->_eqfil0->bw = _private->bandwidthRamp.getValue();
        _private->_eqfil1->bw = _private->bandwidthRamp.getValue();
        _private->_eqfil0->gain = _private->gainRamp.getValue();
        _private->_eqfil1->gain = _private->gainRamp.getValue();

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
                sp_eqfil_compute(_sp, _private->_eqfil0, in, out);
            } else {
                sp_eqfil_compute(_sp, _private->_eqfil1, in, out);
            }
        }
    }
}
