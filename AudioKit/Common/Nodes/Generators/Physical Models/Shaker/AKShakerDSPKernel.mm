//
//  AKShakerDSPKernel.cpp
//  AudioKit
//
//  Created by Stéphane Peter, revision history on Githbub.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#include "AKShakerDSPKernel.hpp"

#include "Shakers.h"

struct AKShakerDSPKernel::_Internal
{
    float internalTrigger = 0;
    
    stk::Shakers *shaker;
    
    UInt8 type = 0;
    float amplitude = 0.5;
};

AKShakerDSPKernel::AKShakerDSPKernel() : _private(new _Internal) {}

AKShakerDSPKernel::~AKShakerDSPKernel() = default;

void AKShakerDSPKernel::init(int _channels, double _sampleRate) {
    AKDSPKernel::init(_channels, _sampleRate);
    
    stk::Stk::setSampleRate(sampleRate);
    _private->shaker = new stk::Shakers(0);
}

void AKShakerDSPKernel::start() {
    started = true;
}

void AKShakerDSPKernel::stop() {
    started = false;
}

void AKShakerDSPKernel::destroy() {
    delete _private->shaker;
}

void AKShakerDSPKernel::reset() {
    resetted = true;
}

void AKShakerDSPKernel::setType(UInt8 typ) {
    _private->type = typ;
}

void AKShakerDSPKernel::setAmplitude(float amp) {
    _private->amplitude = amp;
    amplitudeRamper.setImmediate(amp);
}

void AKShakerDSPKernel::trigger() {
    _private->internalTrigger = 1;
}

void AKShakerDSPKernel::setParameter(AUParameterAddress address, AUValue value) {
    switch (address) {
            
        case amplitudeAddress:
            amplitudeRamper.setUIValue(clamp(value, (float)0, (float)1));
            break;
            
    }
}

AUValue AKShakerDSPKernel::getParameter(AUParameterAddress address) {
    switch (address) {
        case amplitudeAddress:
            return amplitudeRamper.getUIValue();
            
        default: return 0.0f;
    }
}

void AKShakerDSPKernel::startRamp(AUParameterAddress address, AUValue value, AUAudioFrameCount duration) {
    switch (address) {
        case amplitudeAddress:
            amplitudeRamper.startRamp(clamp(value, (float)0, (float)1), duration);
            break;
            
    }
}

void AKShakerDSPKernel::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {
    
    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        
        int frameOffset = int(frameIndex + bufferOffset);
        
        _private->amplitude = amplitudeRamper.getAndStep();
        
        for (int channel = 0; channel < channels; ++channel) {
            float *out = (float *)outBufferListPtr->mBuffers[channel].mData + frameOffset;
            if (started) {
                if (_private->internalTrigger == 1) {
                    _private->shaker->noteOn(_private->type, _private->amplitude);
                }
            } else {
                *out = 0.0;
            }
            *out = _private->shaker->tick();
        }
    }
    if (_private->internalTrigger == 1) {
        _private->internalTrigger = 0;
    }
}

