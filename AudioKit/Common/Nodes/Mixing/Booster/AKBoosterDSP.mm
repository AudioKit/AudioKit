// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "AKBoosterDSP.hpp"
#import "ParameterRamper.hpp"

extern "C" AKDSPRef createBoosterDSP()
{
    return new AKBoosterDSP();
}

struct AKBoosterDSP::InternalData {
    ParameterRamper leftGainRamp;
    ParameterRamper rightGainRamp;
};

AKBoosterDSP::AKBoosterDSP() : data(new InternalData)
{
    parameters[AKBoosterParameterLeftGain] = &data->leftGainRamp;
    parameters[AKBoosterParameterRightGain] = &data->rightGainRamp;
    
    bCanProcessInPlace = true;
}

void AKBoosterDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset)
{
    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);
        
        float lgain = data->leftGainRamp.getAndStep();
        float rgain = data->rightGainRamp.getAndStep();
        
        for (int channel = 0; channel < channelCount; ++channel) {
            float *in = (float *)inputBufferLists[0]->mBuffers[channel].mData  + frameOffset;
            float *out = (float *)outputBufferLists[0]->mBuffers[channel].mData + frameOffset;
            if (isStarted) {
                if (channel == 0) {
                    *out = *in * lgain;
                } else {
                    *out = *in * rgain;
                }
            } else {
                *out = *in;
            }
        }
    }
}
