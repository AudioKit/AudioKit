//
//  AKLowShelfParametricEqualizerFilterDSP.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#include "AKLowShelfParametricEqualizerFilterDSP.hpp"
#import "AKLinearParameterRamp.hpp"

extern "C" void* createLowShelfParametricEqualizerFilterDSP(int nChannels, double sampleRate) {
    AKLowShelfParametricEqualizerFilterDSP* dsp = new AKLowShelfParametricEqualizerFilterDSP();
    dsp->init(nChannels, sampleRate);
    return dsp;
}

struct AKLowShelfParametricEqualizerFilterDSP::_Internal {
    sp_pareq *_pareq0;
    sp_pareq *_pareq1;
    AKLinearParameterRamp cornerFrequencyRamp;
    AKLinearParameterRamp gainRamp;
    AKLinearParameterRamp qRamp;
};

AKLowShelfParametricEqualizerFilterDSP::AKLowShelfParametricEqualizerFilterDSP() : _private(new _Internal) {
    _private->cornerFrequencyRamp.setTarget(defaultCornerFrequency, true);
    _private->cornerFrequencyRamp.setDurationInSamples(defaultRampDurationSamples);
    _private->gainRamp.setTarget(defaultGain, true);
    _private->gainRamp.setDurationInSamples(defaultRampDurationSamples);
    _private->qRamp.setTarget(defaultQ, true);
    _private->qRamp.setDurationInSamples(defaultRampDurationSamples);
}

// Uses the ParameterAddress as a key
void AKLowShelfParametricEqualizerFilterDSP::setParameter(AUParameterAddress address, AUValue value, bool immediate) {
    switch (address) {
        case AKLowShelfParametricEqualizerFilterParameterCornerFrequency:
            _private->cornerFrequencyRamp.setTarget(clamp(value, cornerFrequencyLowerBound, cornerFrequencyUpperBound), immediate);
            break;
        case AKLowShelfParametricEqualizerFilterParameterGain:
            _private->gainRamp.setTarget(clamp(value, gainLowerBound, gainUpperBound), immediate);
            break;
        case AKLowShelfParametricEqualizerFilterParameterQ:
            _private->qRamp.setTarget(clamp(value, qLowerBound, qUpperBound), immediate);
            break;
        case AKLowShelfParametricEqualizerFilterParameterRampDuration:
            _private->cornerFrequencyRamp.setRampDuration(value, _sampleRate);
            _private->gainRamp.setRampDuration(value, _sampleRate);
            _private->qRamp.setRampDuration(value, _sampleRate);
            break;
    }
}

// Uses the ParameterAddress as a key
float AKLowShelfParametricEqualizerFilterDSP::getParameter(uint64_t address) {
    switch (address) {
        case AKLowShelfParametricEqualizerFilterParameterCornerFrequency:
            return _private->cornerFrequencyRamp.getTarget();
        case AKLowShelfParametricEqualizerFilterParameterGain:
            return _private->gainRamp.getTarget();
        case AKLowShelfParametricEqualizerFilterParameterQ:
            return _private->qRamp.getTarget();
        case AKLowShelfParametricEqualizerFilterParameterRampDuration:
            return _private->cornerFrequencyRamp.getRampDuration(_sampleRate);
    }
    return 0;
}

void AKLowShelfParametricEqualizerFilterDSP::init(int _channels, double _sampleRate) {
    AKSoundpipeDSPBase::init(_channels, _sampleRate);
    sp_pareq_create(&_private->_pareq0);
    sp_pareq_init(_sp, _private->_pareq0);
    sp_pareq_create(&_private->_pareq1);
    sp_pareq_init(_sp, _private->_pareq1);
    _private->_pareq0->fc = defaultCornerFrequency;
    _private->_pareq1->fc = defaultCornerFrequency;
    _private->_pareq0->v = defaultGain;
    _private->_pareq1->v = defaultGain;
    _private->_pareq0->q = defaultQ;
    _private->_pareq1->q = defaultQ;
    _private->_pareq0->mode = 1;
    _private->_pareq1->mode = 1;
}

void AKLowShelfParametricEqualizerFilterDSP::destroy() {
    sp_pareq_destroy(&_private->_pareq0);
    sp_pareq_destroy(&_private->_pareq1);
    AKSoundpipeDSPBase::destroy();
}

void AKLowShelfParametricEqualizerFilterDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);

        // do ramping every 8 samples
        if ((frameOffset & 0x7) == 0) {
            _private->cornerFrequencyRamp.advanceTo(_now + frameOffset);
            _private->gainRamp.advanceTo(_now + frameOffset);
            _private->qRamp.advanceTo(_now + frameOffset);
        }

        _private->_pareq0->fc = _private->cornerFrequencyRamp.getValue();
        _private->_pareq1->fc = _private->cornerFrequencyRamp.getValue();
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
