//
//  AKLowPassButterworthFilterDSP.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#include "AKLowPassButterworthFilterDSP.hpp"
#import "AKLinearParameterRamp.hpp"

extern "C" void* createLowPassButterworthFilterDSP(int nChannels, double sampleRate) {
    AKLowPassButterworthFilterDSP* dsp = new AKLowPassButterworthFilterDSP();
    dsp->init(nChannels, sampleRate);
    return dsp;
}

struct AKLowPassButterworthFilterDSP::_Internal {
    sp_butlp *_butlp0;
    sp_butlp *_butlp1;
    AKLinearParameterRamp cutoffFrequencyRamp;
};

AKLowPassButterworthFilterDSP::AKLowPassButterworthFilterDSP() : _private(new _Internal) {
    _private->cutoffFrequencyRamp.setTarget(defaultCutoffFrequency, true);
    _private->cutoffFrequencyRamp.setDurationInSamples(defaultRampDurationSamples);
}

// Uses the ParameterAddress as a key
void AKLowPassButterworthFilterDSP::setParameter(AUParameterAddress address, AUValue value, bool immediate) {
    switch (address) {
        case AKLowPassButterworthFilterParameterCutoffFrequency:
            _private->cutoffFrequencyRamp.setTarget(clamp(value, cutoffFrequencyLowerBound, cutoffFrequencyUpperBound), immediate);
            break;
        case AKLowPassButterworthFilterParameterRampDuration:
            _private->cutoffFrequencyRamp.setRampDuration(value, _sampleRate);
            break;
    }
}

// Uses the ParameterAddress as a key
float AKLowPassButterworthFilterDSP::getParameter(uint64_t address) {
    switch (address) {
        case AKLowPassButterworthFilterParameterCutoffFrequency:
            return _private->cutoffFrequencyRamp.getTarget();
        case AKLowPassButterworthFilterParameterRampDuration:
            return _private->cutoffFrequencyRamp.getRampDuration(_sampleRate);
    }
    return 0;
}

void AKLowPassButterworthFilterDSP::init(int _channels, double _sampleRate) {
    AKSoundpipeDSPBase::init(_channels, _sampleRate);
    sp_butlp_create(&_private->_butlp0);
    sp_butlp_init(_sp, _private->_butlp0);
    sp_butlp_create(&_private->_butlp1);
    sp_butlp_init(_sp, _private->_butlp1);
    _private->_butlp0->freq = defaultCutoffFrequency;
    _private->_butlp1->freq = defaultCutoffFrequency;
}

void AKLowPassButterworthFilterDSP::destroy() {
    sp_butlp_destroy(&_private->_butlp0);
    sp_butlp_destroy(&_private->_butlp1);
    AKSoundpipeDSPBase::destroy();
}

void AKLowPassButterworthFilterDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);

        // do ramping every 8 samples
        if ((frameOffset & 0x7) == 0) {
            _private->cutoffFrequencyRamp.advanceTo(_now + frameOffset);
        }

        _private->_butlp0->freq = _private->cutoffFrequencyRamp.getValue();
        _private->_butlp1->freq = _private->cutoffFrequencyRamp.getValue();

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
                sp_butlp_compute(_sp, _private->_butlp0, in, out);
            } else {
                sp_butlp_compute(_sp, _private->_butlp1, in, out);
            }
        }
    }
}
