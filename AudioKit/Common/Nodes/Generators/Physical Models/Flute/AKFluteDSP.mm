//
//  AKFlute.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#import "AKFluteDSP.hpp"

#include "Flute.h"

// "Constructor" function for interop with Swift

extern "C" void* createFluteDSP(int nChannels, double sampleRate) {
    AKFluteDSP* dsp = new AKFluteDSP();
    dsp->init(nChannels, sampleRate);
    return dsp;
}

// AKFluteDSP method implementations

struct AKFluteDSP::_Internal
{
    float internalTrigger = 0;
    stk::Flute *flute;

    AKLinearParameterRamp frequencyRamp;
    AKLinearParameterRamp amplitudeRamp;
    AKLinearParameterRamp detuningOffsetRamp;
    AKLinearParameterRamp detuningMultiplierRamp;
};

AKFluteDSP::AKFluteDSP() : _private(new _Internal)
{
    _private->frequencyRamp.setTarget(440, true);
    _private->frequencyRamp.setDurationInSamples(10000);
    _private->amplitudeRamp.setTarget(1, true);
    _private->amplitudeRamp.setDurationInSamples(10000);
}

AKFluteDSP::~AKFluteDSP() = default;

/** Uses the ParameterAddress as a key */
void AKFluteDSP::setParameter(AUParameterAddress address, float value, bool immediate)  {
    switch (address) {
        case AKFluteParameterFrequency:
            _private->frequencyRamp.setTarget(value, immediate);
            break;
        case AKFluteParameterAmplitude:
            _private->amplitudeRamp.setTarget(value, immediate);
            break;
        case AKFluteParameterRampDuration:
            _private->frequencyRamp.setRampDuration(value, _sampleRate);
            _private->amplitudeRamp.setRampDuration(value, _sampleRate);
            break;
    }
}

/** Uses the ParameterAddress as a key */
float AKFluteDSP::getParameter(AUParameterAddress address)  {
    switch (address) {
        case AKFluteParameterFrequency:
            return _private->frequencyRamp.getTarget();
        case AKFluteParameterAmplitude:
            return _private->amplitudeRamp.getTarget();
        case AKFluteParameterRampDuration:
            return _private->frequencyRamp.getRampDuration(_sampleRate);
    }
    return 0;
}

void AKFluteDSP::init(int _channels, double _sampleRate)  {
    AKDSPBase::init(_channels, _sampleRate);

    stk::Stk::setSampleRate(_sampleRate);
    _private->flute = new stk::Flute(100);
}

void AKFluteDSP::trigger() {
    _private->internalTrigger = 1;
}

void AKFluteDSP::triggerFrequencyAmplitude(AUValue freq, AUValue amp)  {
    bool immediate = true;
    _private->frequencyRamp.setTarget(freq, immediate);
    _private->amplitudeRamp.setTarget(amp, immediate);
    trigger();
}

void AKFluteDSP::destroy() {
    delete _private->flute;
}

void AKFluteDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

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
                    _private->flute->noteOn(frequency, amplitude);
                }
                *out = _private->flute->tick();
            } else {
                *out = 0.0;
            }
        }
    }
    if (_private->internalTrigger == 1) {
        _private->internalTrigger = 0;
    }
}

