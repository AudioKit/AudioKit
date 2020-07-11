// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#import "AKClarinetDSP.hpp"

#include "Clarinet.h"

extern "C" AKDSPRef createClarinetDSP() {
    return new AKClarinetDSP();
}

// AKClarinetDSP method implementations

struct AKClarinetDSP::InternalData
{
    float internalTrigger = 0;
    stk::Clarinet *clarinet;

    AKLinearParameterRamp frequencyRamp;
    AKLinearParameterRamp amplitudeRamp;
    AKLinearParameterRamp detuningOffsetRamp;
    AKLinearParameterRamp detuningMultiplierRamp;
};

AKClarinetDSP::AKClarinetDSP() : data(new InternalData)
{
    data->frequencyRamp.setTarget(440, true);
    data->frequencyRamp.setDurationInSamples(10000);
    data->amplitudeRamp.setTarget(1, true);
    data->amplitudeRamp.setDurationInSamples(10000);
}

AKClarinetDSP::~AKClarinetDSP() = default;


/// Uses the ParameterAddress as a key
void AKClarinetDSP::setParameter(AUParameterAddress address, float value, bool immediate)  {
    switch (address) {
        case AKClarinetParameterFrequency:
            data->frequencyRamp.setTarget(value, immediate);
            break;
        case AKClarinetParameterAmplitude:
            data->amplitudeRamp.setTarget(value, immediate);
            break;
        case AKClarinetParameterRampDuration:
            data->frequencyRamp.setRampDuration(value, sampleRate);
            data->amplitudeRamp.setRampDuration(value, sampleRate);
            break;
    }
}

/// Uses the ParameterAddress as a key
float AKClarinetDSP::getParameter(AUParameterAddress address)  {
    switch (address) {
        case AKClarinetParameterFrequency:
            return data->frequencyRamp.getTarget();
        case AKClarinetParameterAmplitude:
            return data->amplitudeRamp.getTarget();
        case AKClarinetParameterRampDuration:
            return data->frequencyRamp.getRampDuration(sampleRate);
    }
    return 0;
}

void AKClarinetDSP::init(int channelCount, double sampleRate)  {
    AKDSPBase::init(channelCount, sampleRate);

    stk::Stk::setSampleRate(sampleRate);
    data->clarinet = new stk::Clarinet(100);
}

void AKClarinetDSP::trigger() {
    data->internalTrigger = 1;
}

void AKClarinetDSP::triggerFrequencyAmplitude(AUValue freq, AUValue amp)  {
    bool immediate = true;
    data->frequencyRamp.setTarget(freq, immediate);
    data->amplitudeRamp.setTarget(amp, immediate);
    trigger();
}

void AKClarinetDSP::deinit() {
    AKDSPBase::deinit();
    delete data->clarinet;
}

void AKClarinetDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

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
            float *out = (float *)outputBufferLists[0]->mBuffers[channel].mData + frameOffset;

            if (isStarted) {
                if (data->internalTrigger == 1) {
                    data->clarinet->noteOn(frequency, amplitude);
                }
                *out = data->clarinet->tick();
            } else {
                *out = 0.0;
            }
        }
    }
    if (data->internalTrigger == 1) {
        data->internalTrigger = 0;
    }
}
