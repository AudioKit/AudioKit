//
//  AKBandRejectButterworthFilterDSP.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#include "AKBandRejectButterworthFilterDSP.hpp"
#import "AKLinearParameterRamp.hpp"

extern "C" void* createBandRejectButterworthFilterDSP(int nChannels, double sampleRate) {
    AKBandRejectButterworthFilterDSP* dsp = new AKBandRejectButterworthFilterDSP();
    dsp->init(nChannels, sampleRate);
    return dsp;
}

struct AKBandRejectButterworthFilterDSP::_Internal {
    sp_butbr *_butbr0;
    sp_butbr *_butbr1;
    AKLinearParameterRamp centerFrequencyRamp;
    AKLinearParameterRamp bandwidthRamp;
};

AKBandRejectButterworthFilterDSP::AKBandRejectButterworthFilterDSP() : _private(new _Internal) {
    _private->centerFrequencyRamp.setTarget(defaultCenterFrequency, true);
    _private->centerFrequencyRamp.setDurationInSamples(defaultRampDurationSamples);
    _private->bandwidthRamp.setTarget(defaultBandwidth, true);
    _private->bandwidthRamp.setDurationInSamples(defaultRampDurationSamples);
}

// Uses the ParameterAddress as a key
void AKBandRejectButterworthFilterDSP::setParameter(AUParameterAddress address, AUValue value, bool immediate) {
    switch (address) {
        case AKBandRejectButterworthFilterParameterCenterFrequency:
            _private->centerFrequencyRamp.setTarget(clamp(value, centerFrequencyLowerBound, centerFrequencyUpperBound), immediate);
            break;
        case AKBandRejectButterworthFilterParameterBandwidth:
            _private->bandwidthRamp.setTarget(clamp(value, bandwidthLowerBound, bandwidthUpperBound), immediate);
            break;
        case AKBandRejectButterworthFilterParameterRampDuration:
            _private->centerFrequencyRamp.setRampDuration(value, _sampleRate);
            _private->bandwidthRamp.setRampDuration(value, _sampleRate);
            break;
    }
}

// Uses the ParameterAddress as a key
float AKBandRejectButterworthFilterDSP::getParameter(uint64_t address) {
    switch (address) {
        case AKBandRejectButterworthFilterParameterCenterFrequency:
            return _private->centerFrequencyRamp.getTarget();
        case AKBandRejectButterworthFilterParameterBandwidth:
            return _private->bandwidthRamp.getTarget();
        case AKBandRejectButterworthFilterParameterRampDuration:
            return _private->centerFrequencyRamp.getRampDuration(_sampleRate);
    }
    return 0;
}

void AKBandRejectButterworthFilterDSP::init(int _channels, double _sampleRate) {
    AKSoundpipeDSPBase::init(_channels, _sampleRate);
    sp_butbr_create(&_private->_butbr0);
    sp_butbr_init(_sp, _private->_butbr0);
    sp_butbr_create(&_private->_butbr1);
    sp_butbr_init(_sp, _private->_butbr1);
    _private->_butbr0->freq = defaultCenterFrequency;
    _private->_butbr1->freq = defaultCenterFrequency;
    _private->_butbr0->bw = defaultBandwidth;
    _private->_butbr1->bw = defaultBandwidth;
}

void AKBandRejectButterworthFilterDSP::destroy() {
    sp_butbr_destroy(&_private->_butbr0);
    sp_butbr_destroy(&_private->_butbr1);
    AKSoundpipeDSPBase::destroy();
}

void AKBandRejectButterworthFilterDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);

        // do ramping every 8 samples
        if ((frameOffset & 0x7) == 0) {
            _private->centerFrequencyRamp.advanceTo(_now + frameOffset);
            _private->bandwidthRamp.advanceTo(_now + frameOffset);
        }

        _private->_butbr0->freq = _private->centerFrequencyRamp.getValue();
        _private->_butbr1->freq = _private->centerFrequencyRamp.getValue();
        _private->_butbr0->bw = _private->bandwidthRamp.getValue();
        _private->_butbr1->bw = _private->bandwidthRamp.getValue();

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
                sp_butbr_compute(_sp, _private->_butbr0, in, out);
            } else {
                sp_butbr_compute(_sp, _private->_butbr1, in, out);
            }
        }
    }
}
