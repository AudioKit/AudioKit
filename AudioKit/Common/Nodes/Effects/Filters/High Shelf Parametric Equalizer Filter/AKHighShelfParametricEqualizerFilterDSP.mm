//
//  AKHighShelfParametricEqualizerFilterDSP.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#include "AKHighShelfParametricEqualizerFilterDSP.hpp"
#import "AKLinearParameterRamp.hpp"

extern "C" void* createHighShelfParametricEqualizerFilterDSP(int nChannels, double sampleRate) {
    AKHighShelfParametricEqualizerFilterDSP* dsp = new AKHighShelfParametricEqualizerFilterDSP();
    dsp->init(nChannels, sampleRate);
    return dsp;
}

struct AKHighShelfParametricEqualizerFilterDSP::_Internal {
    sp_pareq *_pareq0;
    sp_pareq *_pareq1;
    AKLinearParameterRamp centerFrequencyRamp;
    AKLinearParameterRamp gainRamp;
    AKLinearParameterRamp qRamp;
};

AKHighShelfParametricEqualizerFilterDSP::AKHighShelfParametricEqualizerFilterDSP() : _private(new _Internal) {
    _private->centerFrequencyRamp.setTarget(defaultCenterFrequency, true);
    _private->centerFrequencyRamp.setDurationInSamples(defaultRampDurationSamples);
    _private->gainRamp.setTarget(defaultGain, true);
    _private->gainRamp.setDurationInSamples(defaultRampDurationSamples);
    _private->qRamp.setTarget(defaultQ, true);
    _private->qRamp.setDurationInSamples(defaultRampDurationSamples);
}

// Uses the ParameterAddress as a key
void AKHighShelfParametricEqualizerFilterDSP::setParameter(AUParameterAddress address, AUValue value, bool immediate) {
    switch (address) {
        case AKHighShelfParametricEqualizerFilterParameterCenterFrequency:
            _private->centerFrequencyRamp.setTarget(clamp(value, centerFrequencyLowerBound, centerFrequencyUpperBound), immediate);
            break;
        case AKHighShelfParametricEqualizerFilterParameterGain:
            _private->gainRamp.setTarget(clamp(value, gainLowerBound, gainUpperBound), immediate);
            break;
        case AKHighShelfParametricEqualizerFilterParameterQ:
            _private->qRamp.setTarget(clamp(value, qLowerBound, qUpperBound), immediate);
            break;
        case AKHighShelfParametricEqualizerFilterParameterRampDuration:
            _private->centerFrequencyRamp.setRampDuration(value, _sampleRate);
            _private->gainRamp.setRampDuration(value, _sampleRate);
            _private->qRamp.setRampDuration(value, _sampleRate);
            break;
    }
}

// Uses the ParameterAddress as a key
float AKHighShelfParametricEqualizerFilterDSP::getParameter(uint64_t address) {
    switch (address) {
        case AKHighShelfParametricEqualizerFilterParameterCenterFrequency:
            return _private->centerFrequencyRamp.getTarget();
        case AKHighShelfParametricEqualizerFilterParameterGain:
            return _private->gainRamp.getTarget();
        case AKHighShelfParametricEqualizerFilterParameterQ:
            return _private->qRamp.getTarget();
        case AKHighShelfParametricEqualizerFilterParameterRampDuration:
            return _private->centerFrequencyRamp.getRampDuration(_sampleRate);
    }
    return 0;
}

void AKHighShelfParametricEqualizerFilterDSP::init(int _channels, double _sampleRate) {
    AKSoundpipeDSPBase::init(_channels, _sampleRate);
    sp_pareq_create(&_private->_pareq0);
    sp_pareq_init(_sp, _private->_pareq0);
    sp_pareq_create(&_private->_pareq1);
    sp_pareq_init(_sp, _private->_pareq1);
    _private->_pareq0->fc = defaultCenterFrequency;
    _private->_pareq1->fc = defaultCenterFrequency;
    _private->_pareq0->v = defaultGain;
    _private->_pareq1->v = defaultGain;
    _private->_pareq0->q = defaultQ;
    _private->_pareq1->q = defaultQ;
    _private->_pareq0->mode = 2;
    _private->_pareq1->mode = 2;
}

void AKHighShelfParametricEqualizerFilterDSP::destroy() {
    sp_pareq_destroy(&_private->_pareq0);
    sp_pareq_destroy(&_private->_pareq1);
    AKSoundpipeDSPBase::destroy();
}

void AKHighShelfParametricEqualizerFilterDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);

        // do ramping every 8 samples
        if ((frameOffset & 0x7) == 0) {
            _private->centerFrequencyRamp.advanceTo(_now + frameOffset);
            _private->gainRamp.advanceTo(_now + frameOffset);
            _private->qRamp.advanceTo(_now + frameOffset);
        }

        _private->_pareq0->fc = _private->centerFrequencyRamp.getValue();
        _private->_pareq1->fc = _private->centerFrequencyRamp.getValue();
        _private->_pareq0->v = _private->gainRamp.getValue();
        _private->_pareq1->v = _private->gainRamp.getValue();
        _private->_pareq0->q = _private->qRamp.getValue();
        _private->_pareq1->q = _private->qRamp.getValue();

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
                sp_pareq_compute(_sp, _private->_pareq0, in, out);
            } else {
                sp_pareq_compute(_sp, _private->_pareq1, in, out);
            }
        }
    }
}
