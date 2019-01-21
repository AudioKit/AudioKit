//
//  SDBooster.mm
//  ExtendingAudioKit
//
//  Created by Shane Dunne, revision history on Githbub
//  Copyright © 2018 AudioKit. All rights reserved.
//

#include "SDBoosterDSP.hpp"
#import "AKExponentialParameterRamp.hpp"

extern "C" void* createSDBoosterDSP(int nChannels, double sampleRate) {
    SDBoosterDSP* dsp = new SDBoosterDSP();
    dsp->init(nChannels, sampleRate);
    return dsp;
}

struct SDBoosterDSP::_Internal {
    AKExponentialParameterRamp leftGainRamp;
    AKExponentialParameterRamp rightGainRamp;
};

SDBoosterDSP::SDBoosterDSP() : _private(new _Internal) {
    _private->leftGainRamp.setTarget(1.0, true);
    _private->leftGainRamp.setDurationInSamples(10000);
    _private->rightGainRamp.setTarget(1.0, true);
    _private->rightGainRamp.setDurationInSamples(10000);
}

// Uses the ParameterAddress as a key
void SDBoosterDSP::setParameter(AUParameterAddress address, AUValue value, bool immediate) {
    switch (address) {
        case SDBoosterParameterLeftGain:
            _private->leftGainRamp.setTarget(value, immediate);
            break;
        case SDBoosterParameterRightGain:
            _private->rightGainRamp.setTarget(value, immediate);
            break;
        case SDBoosterParameterRampDuration:
            _private->leftGainRamp.setRampDuration(value, sampleRate);
            _private->rightGainRamp.setRampDuration(value, sampleRate);
            break;
    }
}

// Uses the ParameterAddress as a key
float SDBoosterDSP::getParameter(AUParameterAddress address) {
    switch (address) {
        case SDBoosterParameterLeftGain:
            return _private->leftGainRamp.getTarget();
        case SDBoosterParameterRightGain:
            return _private->rightGainRamp.getTarget();
        case SDBoosterParameterRampDuration:
            return _private->leftGainRamp.getRampDuration(sampleRate);
    }
    return 0;
}

void SDBoosterDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);
        // do ramping every 8 samples
        if ((frameOffset & 0x7) == 0) {
            _private->leftGainRamp.advanceTo(now + frameOffset);
            _private->rightGainRamp.advanceTo(now + frameOffset);
        }
        // do actual signal processing
        // After all this scaffolding, the only thing we are doing is scaling the input
        for (int channel = 0; channel < channelCount; ++channel) {
            float* in  = (float*)inBufferListPtr->mBuffers[channel].mData  + frameOffset;
            float* out = (float*)outBufferListPtr->mBuffers[channel].mData + frameOffset;
            if (channel == 0) {
                *out = *in * _private->leftGainRamp.getValue();
            } else {
                *out = *in * _private->rightGainRamp.getValue();
            }
        }
    }
}
