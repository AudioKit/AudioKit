// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "AKDSPBase.hpp"
#include "ParameterRamper.hpp"

enum AKBoosterParameter : AUParameterAddress {
    AKBoosterParameterLeftGain,
    AKBoosterParameterRightGain,
};

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

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {
        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            int frameOffset = int(frameIndex + bufferOffset);

            float lgain = leftGainRamp.getAndStep();
            float rgain = rightGainRamp.getAndStep();

            for (int channel = 0; channel < channelCount; ++channel) {
                float *in = (float *)inputBufferLists[0]->mBuffers[channel].mData  + frameOffset;
                float *out = (float *)outputBufferList->mBuffers[channel].mData + frameOffset;
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

AK_REGISTER_DSP(AKBoosterDSP)
AK_REGISTER_PARAMETER(AKBoosterParameterLeftGain)
AK_REGISTER_PARAMETER(AKBoosterParameterRightGain)

