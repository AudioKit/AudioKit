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

extern "C" AKDSPRef createFluteDSP(int channelCount, double sampleRate) {
    AKFluteDSP *dsp = new AKFluteDSP();
    dsp->init(channelCount, sampleRate);
    return dsp;
}

// AKFluteDSP method implementations

struct AKFluteDSP::InternalData
{
    float internalTrigger = 0;
    stk::Flute *flute;

    AKLinearParameterRamp frequencyRamp;
    AKLinearParameterRamp amplitudeRamp;
    AKLinearParameterRamp detuningOffsetRamp;
    AKLinearParameterRamp detuningMultiplierRamp;
};

AKFluteDSP::AKFluteDSP() : data(new InternalData)
{
    data->frequencyRamp.setTarget(440, true);
    data->frequencyRamp.setDurationInSamples(10000);
    data->amplitudeRamp.setTarget(1, true);
    data->amplitudeRamp.setDurationInSamples(10000);
}

AKFluteDSP::~AKFluteDSP() = default;

/** Uses the ParameterAddress as a key */
void AKFluteDSP::setParameter(AUParameterAddress address, float value, bool immediate)  {
    switch (address) {
        case AKFluteParameterFrequency:
            data->frequencyRamp.setTarget(value, immediate);
            break;
        case AKFluteParameterAmplitude:
            data->amplitudeRamp.setTarget(value, immediate);
            break;
        case AKFluteParameterRampDuration:
            data->frequencyRamp.setRampDuration(value, sampleRate);
            data->amplitudeRamp.setRampDuration(value, sampleRate);
            break;
    }
}

/** Uses the ParameterAddress as a key */
float AKFluteDSP::getParameter(AUParameterAddress address)  {
    switch (address) {
        case AKFluteParameterFrequency:
            return data->frequencyRamp.getTarget();
        case AKFluteParameterAmplitude:
            return data->amplitudeRamp.getTarget();
        case AKFluteParameterRampDuration:
            return data->frequencyRamp.getRampDuration(sampleRate);
    }
    return 0;
}

void AKFluteDSP::init(int channelCount, double sampleRate)  {
    AKDSPBase::init(channelCount, sampleRate);

    stk::Stk::setSampleRate(sampleRate);
    data->flute = new stk::Flute(100);
}

void AKFluteDSP::trigger() {
    data->internalTrigger = 1;
}

void AKFluteDSP::triggerFrequencyAmplitude(AUValue freq, AUValue amp)  {
    bool immediate = true;
    data->frequencyRamp.setTarget(freq, immediate);
    data->amplitudeRamp.setTarget(amp, immediate);
    trigger();
}

void AKFluteDSP::destroy() {
    delete data->flute;
}

void AKFluteDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);

        // do ramping every 8 samples
        if ((frameOffset & 0x7) == 0) {
            data->frequencyRamp.advanceTo(now + frameOffset);
            data->amplitudeRamp.advanceTo(now + frameOffset);
        }
        float frequency = data->frequencyRamp.getValue();
        float amplitude = data->amplitudeRamp.getValue();

        for (int channel = 0; channel < channelCount; ++channel) {
            float *out = (float *)outBufferListPtr->mBuffers[channel].mData + frameOffset;

            if (isStarted) {
                if (data->internalTrigger == 1) {
                    data->flute->noteOn(frequency, amplitude);
                }
                *out = data->flute->tick();
            } else {
                *out = 0.0;
            }
        }
    }
    if (data->internalTrigger == 1) {
        data->internalTrigger = 0;
    }
}

