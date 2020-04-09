//
//  AKBoosterDSP.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#include "AKBoosterDSP.hpp"

extern "C" AKDSPRef createBoosterDSP(int channelCount, double sampleRate)
{
    AKBoosterDSP *dsp = new AKBoosterDSP();
    dsp->init(channelCount, sampleRate);
    return dsp;
}

struct AKBoosterDSP::InternalData {
    AKParameterRamp leftGainRamp;
    AKParameterRamp rightGainRamp;
};

AKBoosterDSP::AKBoosterDSP() : data(new InternalData)
{
    data->leftGainRamp.setTarget(1.0, true);
    data->leftGainRamp.setDurationInSamples(10000);
    data->rightGainRamp.setTarget(1.0, true);
    data->rightGainRamp.setDurationInSamples(10000);
}

// Uses the ParameterAddress as a key
void AKBoosterDSP::setParameter(AUParameterAddress address, AUValue value, bool immediate)
{
    switch (address) {
        case AKBoosterParameterLeftGain:
            data->leftGainRamp.setTarget(value, immediate);
            break;
        case AKBoosterParameterRightGain:
            data->rightGainRamp.setTarget(value, immediate);
            break;
        case AKBoosterParameterRampDuration:
            data->leftGainRamp.setRampDuration(value, sampleRate);
            data->rightGainRamp.setRampDuration(value, sampleRate);
            break;
        case AKBoosterParameterRampType:
            data->leftGainRamp.setRampType(value);
            data->rightGainRamp.setRampType(value);
            break;
    }
}

// Uses the ParameterAddress as a key
float AKBoosterDSP::getParameter(AUParameterAddress address)
{
    switch (address) {
        case AKBoosterParameterLeftGain:
            return data->leftGainRamp.getTarget();
        case AKBoosterParameterRightGain:
            return data->rightGainRamp.getTarget();
        case AKBoosterParameterRampDuration:
            return data->leftGainRamp.getRampDuration(sampleRate);
    }
    return 0;
}

void AKBoosterDSP::start() {
    isStarted = true;
}

void AKBoosterDSP::stop() {
    isStarted = false;
}

void AKBoosterDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset)
{
    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);
        // do ramping every 8 samples
        if (isStarted && (frameOffset & 0x7) == 0) {
            data->leftGainRamp.advanceTo(now + frameOffset);
            data->rightGainRamp.advanceTo(now + frameOffset);
        }
        // do actual signal processing
        // After all this scaffolding, the only thing we are doing is scaling the input
        for (int channel = 0; channel < channelCount; ++channel) {
            float *in = (float *)inBufferListPtr->mBuffers[channel].mData  + frameOffset;
            float *out = (float *)outBufferListPtr->mBuffers[channel].mData + frameOffset;
            if (isStarted) {
                if (channel == 0) {
                    *out = *in * data->leftGainRamp.getValue();
                } else {
                    *out = *in * data->rightGainRamp.getValue();
                }
            } else {
                *out = *in;
            }
        }
    }
}
