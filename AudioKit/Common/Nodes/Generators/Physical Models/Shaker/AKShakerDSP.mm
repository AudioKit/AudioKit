//
//  AKShakerDSP.mm
//  AudioKit
//
//  Created by Aurelius Prochazka on 12/30/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#import "AKShakerDSP.hpp"

#include "Shakers.h"

// "Constructor" function for interop with Swift

extern "C" AKDSPRef createShakerDSP(int nChannels, double sampleRate) {
    AKShakerDSP *dsp = new AKShakerDSP();
    dsp->init(nChannels, sampleRate);
    return dsp;
}

// AKShakerDSP method implementations

struct AKShakerDSP::_Internal
{
    float internalTrigger = 0;
    UInt8 type = 0;
    float amplitude = 0.5;
    stk::Shakers *shaker;
};

AKShakerDSP::AKShakerDSP() : _private(new _Internal)
{
}

AKShakerDSP::~AKShakerDSP() = default;

/** Uses the ParameterAddress as a key */
void AKShakerDSP::setParameter(AUParameterAddress address, float value, bool immediate)  {
}

/** Uses the ParameterAddress as a key */
float AKShakerDSP::getParameter(AUParameterAddress address)  {
    return 0;
}

void AKShakerDSP::init(int _channels, double _sampleRate)  {
    AKDSPBase::init(_channels, _sampleRate);

    stk::Stk::setSampleRate(_sampleRate);
    _private->shaker = new stk::Shakers();
}

void AKShakerDSP::trigger() {
    _private->internalTrigger = 1;
}

void AKShakerDSP::triggerTypeAmplitude(AUValue type, AUValue amp)  {
    _private->type = type;
    _private->amplitude = amp;
    trigger();
}

void AKShakerDSP::destroy() {
    delete _private->shaker;
}

void AKShakerDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);

        for (int channel = 0; channel < _nChannels; ++channel) {
            float *out = (float *)_outBufferListPtr->mBuffers[channel].mData + frameOffset;

            if (_playing) {
                if (_private->internalTrigger == 1) {
                    _private->shaker->noteOn(_private->type, _private->amplitude);
                }
                *out = _private->shaker->tick();
            } else {
                *out = 0.0;
            }
        }
    }
    if (_private->internalTrigger == 1) {
        _private->internalTrigger = 0;
    }
}

