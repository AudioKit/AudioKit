//
//  AKBandPassButterworthFilterDSP.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#include "AKBandPassButterworthFilterDSP.hpp"
#import "AKLinearParameterRamp.hpp"

extern "C" void* createBandPassButterworthFilterDSP(int nChannels, double sampleRate) {
    AKBandPassButterworthFilterDSP* dsp = new AKBandPassButterworthFilterDSP();
    dsp->init(nChannels, sampleRate);
    return dsp;
}

struct AKBandPassButterworthFilterDSP::_Internal {
    sp_butbp *_butbp0;
    sp_butbp *_butbp1;
    AKLinearParameterRamp centerFrequencyRamp;
    AKLinearParameterRamp bandwidthRamp;
};

AKBandPassButterworthFilterDSP::AKBandPassButterworthFilterDSP() : _private(new _Internal) {
    _private->centerFrequencyRamp.setTarget(defaultCenterFrequency, true);
    _private->centerFrequencyRamp.setDurationInSamples(defaultRampDurationSamples);
    _private->bandwidthRamp.setTarget(defaultBandwidth, true);
    _private->bandwidthRamp.setDurationInSamples(defaultRampDurationSamples);
}

// Uses the ParameterAddress as a key
void AKBandPassButterworthFilterDSP::setParameter(AUParameterAddress address, AUValue value, bool immediate) {
    switch (address) {
        case AKBandPassButterworthFilterParameterCenterFrequency:
            _private->centerFrequencyRamp.setTarget(clamp(value, centerFrequencyLowerBound, centerFrequencyUpperBound), immediate);
            break;
        case AKBandPassButterworthFilterParameterBandwidth:
            _private->bandwidthRamp.setTarget(clamp(value, bandwidthLowerBound, bandwidthUpperBound), immediate);
            break;
        case AKBandPassButterworthFilterParameterRampDuration:
            _private->centerFrequencyRamp.setRampDuration(value, _sampleRate);
            _private->bandwidthRamp.setRampDuration(value, _sampleRate);
            break;
    }
}

// Uses the ParameterAddress as a key
float AKBandPassButterworthFilterDSP::getParameter(uint64_t address) {
    switch (address) {
        case AKBandPassButterworthFilterParameterCenterFrequency:
            return _private->centerFrequencyRamp.getTarget();
        case AKBandPassButterworthFilterParameterBandwidth:
            return _private->bandwidthRamp.getTarget();
        case AKBandPassButterworthFilterParameterRampDuration:
            return _private->centerFrequencyRamp.getRampDuration(_sampleRate);
    }
    return 0;
}

void AKBandPassButterworthFilterDSP::init(int _channels, double _sampleRate) {
    AKSoundpipeDSPBase::init(_channels, _sampleRate);
    sp_butbp_create(&_private->_butbp0);
    sp_butbp_init(_sp, _private->_butbp0);
    sp_butbp_create(&_private->_butbp1);
    sp_butbp_init(_sp, _private->_butbp1);
    _private->_butbp0->freq = defaultCenterFrequency;
    _private->_butbp1->freq = defaultCenterFrequency;
    _private->_butbp0->bw = defaultBandwidth;
    _private->_butbp1->bw = defaultBandwidth;
}

void AKBandPassButterworthFilterDSP::destroy() {
    sp_butbp_destroy(&_private->_butbp0);
    sp_butbp_destroy(&_private->_butbp1);
    AKSoundpipeDSPBase::destroy();
}

void AKBandPassButterworthFilterDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);

        // do ramping every 8 samples
        if ((frameOffset & 0x7) == 0) {
            _private->centerFrequencyRamp.advanceTo(_now + frameOffset);
            _private->bandwidthRamp.advanceTo(_now + frameOffset);
        }

        _private->_butbp0->freq = _private->centerFrequencyRamp.getValue();
        _private->_butbp1->freq = _private->centerFrequencyRamp.getValue();
        _private->_butbp0->bw = _private->bandwidthRamp.getValue();
        _private->_butbp1->bw = _private->bandwidthRamp.getValue();

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
                sp_butbp_compute(_sp, _private->_butbp0, in, out);
            } else {
                sp_butbp_compute(_sp, _private->_butbp1, in, out);
            }
        }
    }
}
