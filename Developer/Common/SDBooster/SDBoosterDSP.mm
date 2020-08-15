// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "SDBoosterDSP.hpp"

struct SDBoosterDSP : AKDSPBase {
private:
    ParameterRamper leftGainRamp;
    ParameterRamper rightGainRamp;

public:
    SDBoosterDSP() {
        parameters[SDBoosterParameterLeftGain] = &leftGainRamp;
        parameters[SDBoosterParameterRightGain] = &rightGainRamp;

        bCanProcessInPlace = true;
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {
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

extern "C" AKDSPRef createSDBoosterDSP()
{
    return new SDBoosterDSP();
}

