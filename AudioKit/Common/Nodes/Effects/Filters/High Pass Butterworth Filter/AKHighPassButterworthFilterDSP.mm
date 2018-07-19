//
//  AKHighPassButterworthFilterDSP.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#include "AKHighPassButterworthFilterDSP.hpp"
#import "AKLinearParameterRamp.hpp"

extern "C" void* createHighPassButterworthFilterDSP(int nChannels, double sampleRate) {
    AKHighPassButterworthFilterDSP* dsp = new AKHighPassButterworthFilterDSP();
    dsp->init(nChannels, sampleRate);
    return dsp;
}

struct AKHighPassButterworthFilterDSP::_Internal {
    sp_buthp *_buthp0;
    sp_buthp *_buthp1;
    AKLinearParameterRamp cutoffFrequencyRamp;
};

AKHighPassButterworthFilterDSP::AKHighPassButterworthFilterDSP() : _private(new _Internal) {
    _private->cutoffFrequencyRamp.setTarget(defaultCutoffFrequency, true);
    _private->cutoffFrequencyRamp.setDurationInSamples(defaultRampDurationSamples);
}

// Uses the ParameterAddress as a key
void AKHighPassButterworthFilterDSP::setParameter(AUParameterAddress address, AUValue value, bool immediate) {
    switch (address) {
        case AKHighPassButterworthFilterParameterCutoffFrequency:
            _private->cutoffFrequencyRamp.setTarget(clamp(value, cutoffFrequencyLowerBound, cutoffFrequencyUpperBound), immediate);
            break;
        case AKHighPassButterworthFilterParameterRampDuration:
            _private->cutoffFrequencyRamp.setRampDuration(value, _sampleRate);
            break;
    }
}

// Uses the ParameterAddress as a key
float AKHighPassButterworthFilterDSP::getParameter(uint64_t address) {
    switch (address) {
        case AKHighPassButterworthFilterParameterCutoffFrequency:
            return _private->cutoffFrequencyRamp.getTarget();
        case AKHighPassButterworthFilterParameterRampDuration:
            return _private->cutoffFrequencyRamp.getRampDuration(_sampleRate);
    }
    return 0;
}

void AKHighPassButterworthFilterDSP::init(int _channels, double _sampleRate) {
    AKSoundpipeDSPBase::init(_channels, _sampleRate);
    sp_buthp_create(&_private->_buthp0);
    sp_buthp_init(_sp, _private->_buthp0);
    sp_buthp_create(&_private->_buthp1);
    sp_buthp_init(_sp, _private->_buthp1);
    _private->_buthp0->freq = defaultCutoffFrequency;
    _private->_buthp1->freq = defaultCutoffFrequency;
}

void AKHighPassButterworthFilterDSP::destroy() {
    sp_buthp_destroy(&_private->_buthp0);
    sp_buthp_destroy(&_private->_buthp1);
    AKSoundpipeDSPBase::destroy();
}

void AKHighPassButterworthFilterDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);

        // do ramping every 8 samples
        if ((frameOffset & 0x7) == 0) {
            _private->cutoffFrequencyRamp.advanceTo(_now + frameOffset);
        }

        _private->_buthp0->freq = _private->cutoffFrequencyRamp.getValue();
        _private->_buthp1->freq = _private->cutoffFrequencyRamp.getValue();

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
                sp_buthp_compute(_sp, _private->_buthp0, in, out);
            } else {
                sp_buthp_compute(_sp, _private->_buthp1, in, out);
            }
        }
    }
}
