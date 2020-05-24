// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#import "AKShakerDSP.hpp"

#include "Shakers.h"

// "Constructor" function for interop with Swift

extern "C" AKDSPRef createShakerDSP() {
    AKShakerDSP *dsp = new AKShakerDSP();
    return dsp;
}

extern "C" void triggerTypeShakerDSP(AKDSPRef dsp, AUValue type, AUValue amplitude) {
    ((AKShakerDSP*)dsp)->triggerTypeAmplitude(type, amplitude);
}

// AKShakerDSP method implementations

struct AKShakerDSP::InternalData
{
    float internalTrigger = 0;
    UInt8 type = 0;
    float amplitude = 0.5;
    stk::Shakers *shaker;
};

AKShakerDSP::AKShakerDSP() : data(new InternalData)
{
}

AKShakerDSP::~AKShakerDSP() = default;

/// Uses the ParameterAddress as a key
void AKShakerDSP::setParameter(AUParameterAddress address, float value, bool immediate)  {
    switch (address) {
        case AKShakerParameterType:
            data->type = (UInt8)value;
            break;
        case AKShakerParameterAmplitude:
            data->amplitude = value;
            break;
    }
}

/// Uses the ParameterAddress as a key
float AKShakerDSP::getParameter(AUParameterAddress address)  {
    return 0;
}

void AKShakerDSP::init(int channelCount, double sampleRate)  {
    AKDSPBase::init(channelCount, sampleRate);

    stk::Stk::setSampleRate(sampleRate);
    data->shaker = new stk::Shakers();
}

void AKShakerDSP::trigger() {
    data->internalTrigger = 1;
}

void AKShakerDSP::handleMIDIEvent(AUMIDIEvent const& midiEvent) {
    uint8_t veloc = midiEvent.data[2];
    data->type = (UInt8)midiEvent.data[1];
    data->amplitude = (AUValue)veloc / 127.0;
    trigger();
}

void AKShakerDSP::triggerTypeAmplitude(AUValue type, AUValue amp)  {
    data->type = type;
    data->amplitude = amp;
    trigger();
}

void AKShakerDSP::deinit() {
    AKDSPBase::deinit();
    delete data->shaker;
}

void AKShakerDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);

        for (int channel = 0; channel < channelCount; ++channel) {
            float *out = (float *)outputBufferLists[0]->mBuffers[channel].mData + frameOffset;

            if (isStarted) {
                if (data->internalTrigger == 1) {
                    float frequency = pow(2.0, (data->type - 69.0) / 12.0) * 440.0;
                    data->shaker->noteOn(frequency, data->amplitude);
                }
                *out = data->shaker->tick();
            } else {
                *out = 0.0;
            }
        }
    }
    if (data->internalTrigger == 1) {
        data->internalTrigger = 0;
    }
}

