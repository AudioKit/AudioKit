//
//  AKVariableDelayDSP.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#include "AKVariableDelayDSP.hpp"
#import "AKLinearParameterRamp.hpp"

extern "C" void* createVariableDelayDSP(int nChannels, double sampleRate) {
    AKVariableDelayDSP* dsp = new AKVariableDelayDSP();
    dsp->init(nChannels, sampleRate);
    return dsp;
}

struct AKVariableDelayDSP::_Internal {
    sp_vdelay *_vdelay0;
    sp_vdelay *_vdelay1;
    AKLinearParameterRamp timeRamp;
    AKLinearParameterRamp feedbackRamp;
};

AKVariableDelayDSP::AKVariableDelayDSP() : _private(new _Internal) {
    _private->timeRamp.setTarget(defaultTime, true);
    _private->timeRamp.setDurationInSamples(defaultRampDurationSamples);
    _private->feedbackRamp.setTarget(defaultFeedback, true);
    _private->feedbackRamp.setDurationInSamples(defaultRampDurationSamples);
}

// Uses the ParameterAddress as a key
void AKVariableDelayDSP::setParameter(AUParameterAddress address, AUValue value, bool immediate) {
    switch (address) {
        case AKVariableDelayParameterTime:
            _private->timeRamp.setTarget(clamp(value, timeLowerBound, timeUpperBound), immediate);
            break;
        case AKVariableDelayParameterFeedback:
            _private->feedbackRamp.setTarget(clamp(value, feedbackLowerBound, feedbackUpperBound), immediate);
            break;
        case AKVariableDelayParameterRampDuration:
            _private->timeRamp.setRampDuration(value, _sampleRate);
            _private->feedbackRamp.setRampDuration(value, _sampleRate);
            break;
    }
}

// Uses the ParameterAddress as a key
float AKVariableDelayDSP::getParameter(uint64_t address) {
    switch (address) {
        case AKVariableDelayParameterTime:
            return _private->timeRamp.getTarget();
        case AKVariableDelayParameterFeedback:
            return _private->feedbackRamp.getTarget();
        case AKVariableDelayParameterRampDuration:
            return _private->timeRamp.getRampDuration(_sampleRate);
    }
    return 0;
}

void AKVariableDelayDSP::init(int _channels, double _sampleRate) {
    AKSoundpipeDSPBase::init(_channels, _sampleRate);
    sp_vdelay_create(&_private->_vdelay0);
    sp_vdelay_init(_sp, _private->_vdelay0, 10);
    sp_vdelay_create(&_private->_vdelay1);
    sp_vdelay_init(_sp, _private->_vdelay1, 10 );
    _private->_vdelay0->del = defaultTime;
    _private->_vdelay1->del = defaultTime;
    _private->_vdelay0->feedback = defaultFeedback;
    _private->_vdelay1->feedback = defaultFeedback;
}

void AKVariableDelayDSP::destroy() {
    sp_vdelay_destroy(&_private->_vdelay0);
    sp_vdelay_destroy(&_private->_vdelay1);
    AKSoundpipeDSPBase::destroy();
}

void AKVariableDelayDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);

        // do ramping every 8 samples
        if ((frameOffset & 0x7) == 0) {
            _private->timeRamp.advanceTo(_now + frameOffset);
            _private->feedbackRamp.advanceTo(_now + frameOffset);
        }

        _private->_vdelay0->del = _private->timeRamp.getValue();
        _private->_vdelay1->del = _private->timeRamp.getValue();
        _private->_vdelay0->feedback = _private->feedbackRamp.getValue();
        _private->_vdelay1->feedback = _private->feedbackRamp.getValue();

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
                sp_vdelay_compute(_sp, _private->_vdelay0, in, out);
            } else {
                sp_vdelay_compute(_sp, _private->_vdelay1, in, out);
            }
        }
    }
}
