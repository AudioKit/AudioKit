//
//  AKResonantFilterDSP.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#include "AKResonantFilterDSP.hpp"
#import "AKLinearParameterRamp.hpp"

extern "C" void* createResonantFilterDSP(int nChannels, double sampleRate) {
    AKResonantFilterDSP* dsp = new AKResonantFilterDSP();
    dsp->init(nChannels, sampleRate);
    return dsp;
}

struct AKResonantFilterDSP::_Internal {
    sp_reson *_reson0;
    sp_reson *_reson1;
    AKLinearParameterRamp frequencyRamp;
    AKLinearParameterRamp bandwidthRamp;
};

AKResonantFilterDSP::AKResonantFilterDSP() : _private(new _Internal) {
    _private->frequencyRamp.setTarget(defaultFrequency, true);
    _private->frequencyRamp.setDurationInSamples(defaultRampDurationSamples);
    _private->bandwidthRamp.setTarget(defaultBandwidth, true);
    _private->bandwidthRamp.setDurationInSamples(defaultRampDurationSamples);
}

// Uses the ParameterAddress as a key
void AKResonantFilterDSP::setParameter(AUParameterAddress address, AUValue value, bool immediate) {
    switch (address) {
        case AKResonantFilterParameterFrequency:
            _private->frequencyRamp.setTarget(clamp(value, frequencyLowerBound, frequencyUpperBound), immediate);
            break;
        case AKResonantFilterParameterBandwidth:
            _private->bandwidthRamp.setTarget(clamp(value, bandwidthLowerBound, bandwidthUpperBound), immediate);
            break;
        case AKResonantFilterParameterRampDuration:
            _private->frequencyRamp.setRampDuration(value, _sampleRate);
            _private->bandwidthRamp.setRampDuration(value, _sampleRate);
            break;
    }
}

// Uses the ParameterAddress as a key
float AKResonantFilterDSP::getParameter(uint64_t address) {
    switch (address) {
        case AKResonantFilterParameterFrequency:
            return _private->frequencyRamp.getTarget();
        case AKResonantFilterParameterBandwidth:
            return _private->bandwidthRamp.getTarget();
        case AKResonantFilterParameterRampDuration:
            return _private->frequencyRamp.getRampDuration(_sampleRate);
    }
    return 0;
}

void AKResonantFilterDSP::init(int _channels, double _sampleRate) {
    AKSoundpipeDSPBase::init(_channels, _sampleRate);
    sp_reson_create(&_private->_reson0);
    sp_reson_init(_sp, _private->_reson0);
    sp_reson_create(&_private->_reson1);
    sp_reson_init(_sp, _private->_reson1);
    _private->_reson0->freq = defaultFrequency;
    _private->_reson1->freq = defaultFrequency;
    _private->_reson0->bw = defaultBandwidth;
    _private->_reson1->bw = defaultBandwidth;
}

void AKResonantFilterDSP::destroy() {
    sp_reson_destroy(&_private->_reson0);
    sp_reson_destroy(&_private->_reson1);
    AKSoundpipeDSPBase::destroy();
}

void AKResonantFilterDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);

        // do ramping every 8 samples
        if ((frameOffset & 0x7) == 0) {
            _private->frequencyRamp.advanceTo(_now + frameOffset);
            _private->bandwidthRamp.advanceTo(_now + frameOffset);
        }

        _private->_reson0->freq = _private->frequencyRamp.getValue();
        _private->_reson1->freq = _private->frequencyRamp.getValue();
        _private->_reson0->bw = _private->bandwidthRamp.getValue();
        _private->_reson1->bw = _private->bandwidthRamp.getValue();

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
                sp_reson_compute(_sp, _private->_reson0, in, out);
            } else {
                sp_reson_compute(_sp, _private->_reson1, in, out);
            }
        }
    }
}
