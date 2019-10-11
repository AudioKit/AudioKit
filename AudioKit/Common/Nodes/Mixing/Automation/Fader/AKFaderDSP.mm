//
//  AKFaderDSP.mm
//  AudioKit
//
//  Created by Ryan Francesconi, revision history on Github.
//  Copyright © 2019 AudioKit. All rights reserved.
//

#include "AKFaderDSP.hpp"
#import "ParameterRamper.hpp"

extern "C" AKDSPRef createFaderDSP(int channelCount, double sampleRate)
{
    AKFaderDSP *dsp = new AKFaderDSP();
    dsp->init(channelCount, sampleRate);
    return dsp;
}

struct AKFaderDSP::InternalData {
    ParameterRamper leftGainRamp = 1.0;
    ParameterRamper rightGainRamp = 1.0;
};

AKFaderDSP::AKFaderDSP() : data(new InternalData)
{
}

// Uses the ParameterAddress as a key
void AKFaderDSP::setParameter(AUParameterAddress address, AUValue value, bool immediate)
{
    switch (address) {
        case AKFaderParameterLeftGain:
            // printf("Setting AKFaderParameterLeftGain %f\n", value);

            data->leftGainRamp.setUIValue(value);
            // ramp to the new value
            data->leftGainRamp.dezipperCheck(1024);
            break;
        case AKFaderParameterRightGain:
            // printf("Setting AKFaderParameterRightGain %f\n", value);

            data->rightGainRamp.setUIValue(value);
            // ramp to the new value
            data->rightGainRamp.dezipperCheck(1024);

            break;
    }
}

// Uses the ParameterAddress as a key
float AKFaderDSP::getParameter(AUParameterAddress address)
{
    switch (address) {
        case AKFaderParameterLeftGain:
            return data->leftGainRamp.getUIValue();
        case AKFaderParameterRightGain:
            return data->rightGainRamp.getUIValue();
    }
    return 0;
}

void AKFaderDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset)
{
    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);

        // do actual signal processing
        // After all this scaffolding, the only thing we are doing is scaling the input
        for (int channel = 0; channel < channelCount; ++channel) {
            float *in = (float *)inBufferListPtr->mBuffers[channel].mData  + frameOffset;
            float *out = (float *)outBufferListPtr->mBuffers[channel].mData + frameOffset;
            if (channel == 0) {
                *out = *in * data->leftGainRamp.getAndStep();
            } else {
                *out = *in * data->rightGainRamp.getAndStep();
            }
        }
    }
}

void AKFaderDSP::startRamp(AUParameterAddress address, AUValue value, AUAudioFrameCount duration)
{
    // printf("AKFaderDSP.startRamp() address %lld, value %f, duration %d\n", address, value, duration);

    // Note, if duration is 0 frames, startRamp will setImmediate
    switch (address) {
        case AKFaderParameterLeftGain:
            data->leftGainRamp.startRamp(value, duration);
            break;

        case AKFaderParameterRightGain:
            data->rightGainRamp.startRamp(value, duration);
            break;
    }
}
