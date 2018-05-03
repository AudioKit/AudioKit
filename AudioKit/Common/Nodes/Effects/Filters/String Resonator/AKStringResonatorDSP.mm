//
//  AKStringResonatorDSP.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#include "AKStringResonatorDSP.hpp"
#import "AKLinearParameterRamp.hpp"

extern "C" void* createStringResonatorDSP(int nChannels, double sampleRate) {
    AKStringResonatorDSP* dsp = new AKStringResonatorDSP();
    dsp->init(nChannels, sampleRate);
    return dsp;
}

struct AKStringResonatorDSP::_Internal {
    sp_streson *_streson0;
    sp_streson *_streson1;
    AKLinearParameterRamp fundamentalFrequencyRamp;
    AKLinearParameterRamp feedbackRamp;
};

AKStringResonatorDSP::AKStringResonatorDSP() : _private(new _Internal) {
    _private->fundamentalFrequencyRamp.setTarget(defaultFundamentalFrequency, true);
    _private->fundamentalFrequencyRamp.setDurationInSamples(defaultRampDurationSamples);
    _private->feedbackRamp.setTarget(defaultFeedback, true);
    _private->feedbackRamp.setDurationInSamples(defaultRampDurationSamples);
}

// Uses the ParameterAddress as a key
void AKStringResonatorDSP::setParameter(AUParameterAddress address, AUValue value, bool immediate) {
    switch (address) {
        case AKStringResonatorParameterFundamentalFrequency:
            _private->fundamentalFrequencyRamp.setTarget(clamp(value, fundamentalFrequencyLowerBound, fundamentalFrequencyUpperBound), immediate);
            break;
        case AKStringResonatorParameterFeedback:
            _private->feedbackRamp.setTarget(clamp(value, feedbackLowerBound, feedbackUpperBound), immediate);
            break;
        case AKStringResonatorParameterRampDuration:
            _private->fundamentalFrequencyRamp.setRampDuration(value, _sampleRate);
            _private->feedbackRamp.setRampDuration(value, _sampleRate);
            break;
    }
}

// Uses the ParameterAddress as a key
float AKStringResonatorDSP::getParameter(uint64_t address) {
    switch (address) {
        case AKStringResonatorParameterFundamentalFrequency:
            return _private->fundamentalFrequencyRamp.getTarget();
        case AKStringResonatorParameterFeedback:
            return _private->feedbackRamp.getTarget();
        case AKStringResonatorParameterRampDuration:
            return _private->fundamentalFrequencyRamp.getRampDuration(_sampleRate);
    }
    return 0;
}

void AKStringResonatorDSP::init(int _channels, double _sampleRate) {
    AKSoundpipeDSPBase::init(_channels, _sampleRate);
    sp_streson_create(&_private->_streson0);
    sp_streson_init(_sp, _private->_streson0);
    sp_streson_create(&_private->_streson1);
    sp_streson_init(_sp, _private->_streson1);
    _private->_streson0->freq = defaultFundamentalFrequency;
    _private->_streson1->freq = defaultFundamentalFrequency;
    _private->_streson0->fdbgain = defaultFeedback;
    _private->_streson1->fdbgain = defaultFeedback;
}

void AKStringResonatorDSP::destroy() {
    sp_streson_destroy(&_private->_streson0);
    sp_streson_destroy(&_private->_streson1);
    AKSoundpipeDSPBase::destroy();
}

void AKStringResonatorDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);

        // do ramping every 8 samples
        if ((frameOffset & 0x7) == 0) {
            _private->fundamentalFrequencyRamp.advanceTo(_now + frameOffset);
            _private->feedbackRamp.advanceTo(_now + frameOffset);
        }

        _private->_streson0->freq = _private->fundamentalFrequencyRamp.getValue();
        _private->_streson1->freq = _private->fundamentalFrequencyRamp.getValue();
        _private->_streson0->fdbgain = _private->feedbackRamp.getValue();
        _private->_streson1->fdbgain = _private->feedbackRamp.getValue();

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
                sp_streson_compute(_sp, _private->_streson0, in, out);
            } else {
                sp_streson_compute(_sp, _private->_streson1, in, out);
            }
        }
    }
}
