//
//  AKBoosterDSP.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#include "AKBoosterDSP.hpp"

extern "C" AKDSPRef createBoosterDSP()
{
    return new AKBoosterDSP();
}

struct AKBoosterDSP::InternalData {
    AKParameterRamp leftGainRamp;
    AKParameterRamp rightGainRamp;
};

AKBoosterDSP::AKBoosterDSP() : data(new InternalData)
{
    parameters[AKBoosterParameterLeftGain] = &data->leftGainRamp;
    parameters[AKBoosterParameterRightGain] = &data->rightGainRamp;
    
    bCanProcessInPlace = true;
}

// Uses the ParameterAddress as a key
void AKBoosterDSP::setParameter(AUParameterAddress address, AUValue value, bool immediate)
{
    if (address == AKBoosterParameterRampType) {
        data->leftGainRamp.setRampType(value);
        data->rightGainRamp.setRampType(value);
    }
    else {
        AKDSPBase::setParameter(address, value, immediate);
    }
}

void AKBoosterDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset)
{
    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);
        // do ramping every 8 samples
        if ((frameOffset & 0x7) == 0) {
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
