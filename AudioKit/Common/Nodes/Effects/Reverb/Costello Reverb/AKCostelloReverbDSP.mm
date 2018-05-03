//
//  AKCostelloReverbDSP.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#include "AKCostelloReverbDSP.hpp"
#import "AKLinearParameterRamp.hpp"

extern "C" void* createCostelloReverbDSP(int nChannels, double sampleRate) {
    AKCostelloReverbDSP* dsp = new AKCostelloReverbDSP();
    dsp->init(nChannels, sampleRate);
    return dsp;
}

struct AKCostelloReverbDSP::_Internal {
    sp_revsc *_revsc;
    AKLinearParameterRamp feedbackRamp;
    AKLinearParameterRamp cutoffFrequencyRamp;
};

AKCostelloReverbDSP::AKCostelloReverbDSP() : _private(new _Internal) {
    _private->feedbackRamp.setTarget(defaultFeedback, true);
    _private->feedbackRamp.setDurationInSamples(defaultRampDurationSamples);
    _private->cutoffFrequencyRamp.setTarget(defaultCutoffFrequency, true);
    _private->cutoffFrequencyRamp.setDurationInSamples(defaultRampDurationSamples);
}

// Uses the ParameterAddress as a key
void AKCostelloReverbDSP::setParameter(AUParameterAddress address, AUValue value, bool immediate) {
    switch (address) {
        case AKCostelloReverbParameterFeedback:
            _private->feedbackRamp.setTarget(clamp(value, feedbackLowerBound, feedbackUpperBound), immediate);
            break;
        case AKCostelloReverbParameterCutoffFrequency:
            _private->cutoffFrequencyRamp.setTarget(clamp(value, cutoffFrequencyLowerBound, cutoffFrequencyUpperBound), immediate);
            break;
        case AKCostelloReverbParameterRampDuration:
            _private->feedbackRamp.setRampDuration(value, _sampleRate);
            _private->cutoffFrequencyRamp.setRampDuration(value, _sampleRate);
            break;
    }
}

// Uses the ParameterAddress as a key
float AKCostelloReverbDSP::getParameter(uint64_t address) {
    switch (address) {
        case AKCostelloReverbParameterFeedback:
            return _private->feedbackRamp.getTarget();
        case AKCostelloReverbParameterCutoffFrequency:
            return _private->cutoffFrequencyRamp.getTarget();
        case AKCostelloReverbParameterRampDuration:
            return _private->feedbackRamp.getRampDuration(_sampleRate);
    }
    return 0;
}

void AKCostelloReverbDSP::init(int _channels, double _sampleRate) {
    AKSoundpipeDSPBase::init(_channels, _sampleRate);
    sp_revsc_create(&_private->_revsc);
    sp_revsc_init(_sp, _private->_revsc);
    _private->_revsc->feedback = defaultFeedback;
    _private->_revsc->lpfreq = defaultCutoffFrequency;
}

void AKCostelloReverbDSP::destroy() {
    sp_revsc_destroy(&_private->_revsc);
    AKSoundpipeDSPBase::destroy();
}

void AKCostelloReverbDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);

        // do ramping every 8 samples
        if ((frameOffset & 0x7) == 0) {
            _private->feedbackRamp.advanceTo(_now + frameOffset);
            _private->cutoffFrequencyRamp.advanceTo(_now + frameOffset);
        }

        _private->_revsc->feedback = _private->feedbackRamp.getValue();
        _private->_revsc->lpfreq = _private->cutoffFrequencyRamp.getValue();

        float *tmpin[2];
        float *tmpout[2];
        for (int channel = 0; channel < _nChannels; ++channel) {
            float *in  = (float *)_inBufferListPtr->mBuffers[channel].mData  + frameOffset;
            float *out = (float *)_outBufferListPtr->mBuffers[channel].mData + frameOffset;
            
            if (channel < 2) {
                tmpin[channel] = in;
                tmpout[channel] = out;
            }
            if (!_playing) {
                *out = *in;
            }
        }
        if (_playing) {
            sp_revsc_compute(_sp, _private->_revsc, tmpin[0], tmpin[1], tmpout[0], tmpout[1]);
        }
    }
}
