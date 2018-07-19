//
//  AKPeakingParametricEqualizerFilterDSP.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#include "AKPeakingParametricEqualizerFilterDSP.hpp"
#import "AKLinearParameterRamp.hpp"

extern "C" void* createPeakingParametricEqualizerFilterDSP(int nChannels, double sampleRate) {
    AKPeakingParametricEqualizerFilterDSP* dsp = new AKPeakingParametricEqualizerFilterDSP();
    dsp->init(nChannels, sampleRate);
    return dsp;
}

struct AKPeakingParametricEqualizerFilterDSP::_Internal {
    sp_pareq *_pareq0;
    sp_pareq *_pareq1;
    AKLinearParameterRamp centerFrequencyRamp;
    AKLinearParameterRamp gainRamp;
    AKLinearParameterRamp qRamp;
};

AKPeakingParametricEqualizerFilterDSP::AKPeakingParametricEqualizerFilterDSP() : _private(new _Internal) {
    _private->centerFrequencyRamp.setTarget(defaultCenterFrequency, true);
    _private->centerFrequencyRamp.setDurationInSamples(defaultRampDurationSamples);
    _private->gainRamp.setTarget(defaultGain, true);
    _private->gainRamp.setDurationInSamples(defaultRampDurationSamples);
    _private->qRamp.setTarget(defaultQ, true);
    _private->qRamp.setDurationInSamples(defaultRampDurationSamples);
}

// Uses the ParameterAddress as a key
void AKPeakingParametricEqualizerFilterDSP::setParameter(AUParameterAddress address, AUValue value, bool immediate) {
    switch (address) {
        case AKPeakingParametricEqualizerFilterParameterCenterFrequency:
            _private->centerFrequencyRamp.setTarget(clamp(value, centerFrequencyLowerBound, centerFrequencyUpperBound), immediate);
            break;
        case AKPeakingParametricEqualizerFilterParameterGain:
            _private->gainRamp.setTarget(clamp(value, gainLowerBound, gainUpperBound), immediate);
            break;
        case AKPeakingParametricEqualizerFilterParameterQ:
            _private->qRamp.setTarget(clamp(value, qLowerBound, qUpperBound), immediate);
            break;
        case AKPeakingParametricEqualizerFilterParameterRampDuration:
            _private->centerFrequencyRamp.setRampDuration(value, _sampleRate);
            _private->gainRamp.setRampDuration(value, _sampleRate);
            _private->qRamp.setRampDuration(value, _sampleRate);
            break;
    }
}

// Uses the ParameterAddress as a key
float AKPeakingParametricEqualizerFilterDSP::getParameter(uint64_t address) {
    switch (address) {
        case AKPeakingParametricEqualizerFilterParameterCenterFrequency:
            return _private->centerFrequencyRamp.getTarget();
        case AKPeakingParametricEqualizerFilterParameterGain:
            return _private->gainRamp.getTarget();
        case AKPeakingParametricEqualizerFilterParameterQ:
            return _private->qRamp.getTarget();
        case AKPeakingParametricEqualizerFilterParameterRampDuration:
            return _private->centerFrequencyRamp.getRampDuration(_sampleRate);
    }
    return 0;
}

void AKPeakingParametricEqualizerFilterDSP::init(int _channels, double _sampleRate) {
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
    _private->_pareq0->mode = 0;
    _private->_pareq1->mode = 0;
}

void AKPeakingParametricEqualizerFilterDSP::destroy() {
    sp_pareq_destroy(&_private->_pareq0);
    sp_pareq_destroy(&_private->_pareq1);
    AKSoundpipeDSPBase::destroy();
}

void AKPeakingParametricEqualizerFilterDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

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
