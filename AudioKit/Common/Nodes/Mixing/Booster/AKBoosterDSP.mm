// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "AKBoosterDSP.hpp"
#import "ParameterRamper.hpp"

#import "AKDSPBase.hpp"

struct AKBoosterDSP : public AKDSPBase {
private:
    ParameterRamper leftGainRamp;
    ParameterRamper rightGainRamp;

public:

    AKBoosterDSP() {
        parameters[AKBoosterParameterLeftGain] = &leftGainRamp;
        parameters[AKBoosterParameterRightGain] = &rightGainRamp;
        bCanProcessInPlace = true;
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {
        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            int frameOffset = int(frameIndex + bufferOffset);

            float lgain = leftGainRamp.getAndStep();
            float rgain = rightGainRamp.getAndStep();

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
};

extern "C" AKDSPRef createBoosterDSP() {
    return new AKBoosterDSP();
}
