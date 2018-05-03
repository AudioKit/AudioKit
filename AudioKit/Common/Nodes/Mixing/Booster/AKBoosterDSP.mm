//
//  AKBoosterDSP.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#include "AKBoosterDSP.hpp"

extern "C" void* createBoosterDSP(int nChannels, double sampleRate) {
    AKBoosterDSP* dsp = new AKBoosterDSP();
    dsp->init(nChannels, sampleRate);
    return dsp;
}

struct AKBoosterDSP::_Internal {
    AKParameterRamp leftGainRamp;
    AKParameterRamp rightGainRamp;
};

AKBoosterDSP::AKBoosterDSP() : _private(new _Internal) {
    _private->leftGainRamp.setTarget(1.0, true);
    _private->leftGainRamp.setDurationInSamples(10000);
    _private->rightGainRamp.setTarget(1.0, true);
    _private->rightGainRamp.setDurationInSamples(10000);
}

// Uses the ParameterAddress as a key
void AKBoosterDSP::setParameter(AUParameterAddress address, AUValue value, bool immediate) {
    switch (address) {
        case AKBoosterParameterLeftGain:
            _private->leftGainRamp.setTarget(value, immediate);
            break;
        case AKBoosterParameterRightGain:
            _private->rightGainRamp.setTarget(value, immediate);
            break;
        case AKBoosterParameterRampDuration:
            _private->leftGainRamp.setRampDuration(value, _sampleRate);
            _private->rightGainRamp.setRampDuration(value, _sampleRate);
            break;
        case AKBoosterParameterRampType:
            _private->leftGainRamp.setRampType(value);
            _private->rightGainRamp.setRampType(value);
            break;
    }
}

// Uses the ParameterAddress as a key
float AKBoosterDSP::getParameter(AUParameterAddress address) {
    switch (address) {
        case AKBoosterParameterLeftGain:
            return _private->leftGainRamp.getTarget();
        case AKBoosterParameterRightGain:
            return _private->rightGainRamp.getTarget();
        case AKBoosterParameterRampDuration:
            return _private->leftGainRamp.getRampDuration(_sampleRate);
    }
    return 0;
}

void AKBoosterDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);
        // do ramping every 8 samples
        if ((frameOffset & 0x7) == 0) {
            _private->leftGainRamp.advanceTo(_now + frameOffset);
            _private->rightGainRamp.advanceTo(_now + frameOffset);
        }
        // do actual signal processing
        // After all this scaffolding, the only thing we are doing is scaling the input
        for (int channel = 0; channel < _nChannels; ++channel) {
            float* in  = (float*)_inBufferListPtr->mBuffers[channel].mData  + frameOffset;
            float* out = (float*)_outBufferListPtr->mBuffers[channel].mData + frameOffset;
            if (channel == 0) {
                *out = *in * _private->leftGainRamp.getValue();
            } else {
                *out = *in * _private->rightGainRamp.getValue();
            }
        }
    }
}
