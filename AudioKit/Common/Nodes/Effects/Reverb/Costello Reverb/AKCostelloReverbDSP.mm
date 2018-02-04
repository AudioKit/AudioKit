//
//  AKCostelloReverbDSP.cpp
//  AudioKit
//
//  Created by Stéphane Peter on 2/3/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#include "AKCostelloReverbDSP.hpp"
#import "AKLinearParameterRamp.hpp"

struct AKCostelloReverbDSP::_Internal {
    sp_revsc *_revsc;
    AKLinearParameterRamp feedbackRamp;
    AKLinearParameterRamp cutoffFrequencyRamp;
};

AKCostelloReverbDSP::AKCostelloReverbDSP() : _private(new _Internal) {
    _private->feedbackRamp.setTarget(0.6, true);
    _private->feedbackRamp.setDurationInSamples(10000);
    _private->cutoffFrequencyRamp.setTarget(4000.0, true);
    _private->cutoffFrequencyRamp.setDurationInSamples(10000);
}

AKCostelloReverbDSP::~AKCostelloReverbDSP() = default;

/** Uses the ParameterAddress as a key */
void AKCostelloReverbDSP::setParameter(AUParameterAddress address, float value, bool immediate) {
    switch (address) {
        case AKCostelloReverbParameterFeedback:
            _private->feedbackRamp.setTarget(value, immediate);
            break;
        case AKCostelloReverbParameterCutoffFrequency:
            _private->cutoffFrequencyRamp.setTarget(value, immediate);
            break;
        case AKCostelloReverbParameterRampTime:
            _private->feedbackRamp.setRampTime(value, _sampleRate);
            _private->cutoffFrequencyRamp.setRampTime(value, _sampleRate);
            break;
    }
}

/** Uses the ParameterAddress as a key */
float AKCostelloReverbDSP::getParameter(AUParameterAddress address) {
    switch (address) {
        case AKCostelloReverbParameterFeedback:
            return _private->feedbackRamp.getTarget();
        case AKCostelloReverbParameterCutoffFrequency:
            return _private->cutoffFrequencyRamp.getTarget();
        case AKCostelloReverbParameterRampTime:
            return _private->feedbackRamp.getRampTime(_sampleRate);
    }
    return 0;
}

void AKCostelloReverbDSP::init(int _channels, double _sampleRate) {
    AKSoundpipeDSPBase::init(_channels, _sampleRate);
    sp_revsc_create(&_private->_revsc);
    sp_revsc_init(_sp, _private->_revsc);
    _private->_revsc->feedback = 0.6;
    _private->_revsc->lpfreq = 4000.0;
}

void AKCostelloReverbDSP::destroy() {
    sp_revsc_destroy(&_private->_revsc);
    AKSoundpipeDSPBase::destroy();
}

void AKCostelloReverbDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {
    
    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);
        
        // do gain ramping every 8 samples
        if ((frameOffset & 0x7) == 0) {
            _private->feedbackRamp.advanceTo(_now + frameOffset);
            _private->cutoffFrequencyRamp.advanceTo(_now + frameOffset);
        }

        _private->_revsc->feedback = _private->feedbackRamp.getValue();
        _private->_revsc->lpfreq = _private->cutoffFrequencyRamp.getValue();
        
        float *tmpin[2];
        float *tmpout[2];
        for (int channel = 0; channel < _nChannels; ++channel) {
            float* in  = (float*)_inBufferListPtr->mBuffers[channel].mData  + frameOffset;
            float* out = (float*)_outBufferListPtr->mBuffers[channel].mData + frameOffset;
            
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
