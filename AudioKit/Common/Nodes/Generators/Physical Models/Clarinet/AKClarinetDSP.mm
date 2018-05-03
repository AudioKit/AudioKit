//
//  AKClarinet.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#import "AKClarinetDSP.hpp"

#include "Clarinet.h"

// "Constructor" function for interop with Swift

extern "C" void* createClarinetDSP(int nChannels, double sampleRate) {
    AKClarinetDSP* dsp = new AKClarinetDSP();
    dsp->init(nChannels, sampleRate);
    return dsp;
}

// AKClarinetDSP method implementations

struct AKClarinetDSP::_Internal
{
    float internalTrigger = 0;
    stk::Clarinet *clarinet;
    
    AKLinearParameterRamp frequencyRamp;
    AKLinearParameterRamp amplitudeRamp;
    AKLinearParameterRamp detuningOffsetRamp;
    AKLinearParameterRamp detuningMultiplierRamp;
};

AKClarinetDSP::AKClarinetDSP() : _private(new _Internal)
{
    _private->frequencyRamp.setTarget(440, true);
    _private->frequencyRamp.setDurationInSamples(10000);
    _private->amplitudeRamp.setTarget(1, true);
    _private->amplitudeRamp.setDurationInSamples(10000);
}

AKClarinetDSP::~AKClarinetDSP() = default;


/** Uses the ParameterAddress as a key */
void AKClarinetDSP::setParameter(AUParameterAddress address, float value, bool immediate)  {
    switch (address) {
        case AKClarinetParameterFrequency:
            _private->frequencyRamp.setTarget(value, immediate);
            break;
        case AKClarinetParameterAmplitude:
            _private->amplitudeRamp.setTarget(value, immediate);
            break;
        case AKClarinetParameterRampDuration:
            _private->frequencyRamp.setRampDuration(value, _sampleRate);
            _private->amplitudeRamp.setRampDuration(value, _sampleRate);
            break;
    }
}

/** Uses the ParameterAddress as a key */
float AKClarinetDSP::getParameter(AUParameterAddress address)  {
    switch (address) {
        case AKClarinetParameterFrequency:
            return _private->frequencyRamp.getTarget();
        case AKClarinetParameterAmplitude:
            return _private->amplitudeRamp.getTarget();
        case AKClarinetParameterRampDuration:
            return _private->frequencyRamp.getRampDuration(_sampleRate);
    }
    return 0;
}

void AKClarinetDSP::init(int _channels, double _sampleRate)  {
    AKDSPBase::init(_channels, _sampleRate);
    
    stk::Stk::setSampleRate(_sampleRate);
    _private->clarinet = new stk::Clarinet(100);
}

void AKClarinetDSP::trigger() {
    _private->internalTrigger = 1;
}

void AKClarinetDSP::triggerFrequencyAmplitude(AUValue freq, AUValue amp)  {
    bool immediate = true;
    _private->frequencyRamp.setTarget(freq, immediate);
    _private->amplitudeRamp.setTarget(amp, immediate);
    trigger();
}

void AKClarinetDSP::destroy() {
    delete _private->clarinet;
}

void AKClarinetDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {
    
    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);
        
        // do ramping every 8 samples
        if ((frameOffset & 0x7) == 0) {
            _private->frequencyRamp.advanceTo(_now + frameOffset);
            _private->amplitudeRamp.advanceTo(_now + frameOffset);
        }
        float frequency = _private->frequencyRamp.getValue();
        float amplitude = _private->amplitudeRamp.getValue();
        
        for (int channel = 0; channel < _nChannels; ++channel) {
            float* out = (float *)_outBufferListPtr->mBuffers[channel].mData + frameOffset;
            
            if (_playing) {
                if (_private->internalTrigger == 1) {
                    _private->clarinet->noteOn(frequency, amplitude);
                }
                *out = _private->clarinet->tick();
            } else {
                *out = 0.0;
            }
        }
    }
    if (_private->internalTrigger == 1) {
        _private->internalTrigger = 0;
    }
}
