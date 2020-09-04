// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "AKSoundpipeDSPBase.hpp"
#include "ParameterRamper.hpp"

enum AKDryWetMixerParameter : AUParameterAddress {
    AKDryWetMixerParameterBalance,
};

class AKDryWetMixerDSP : public AKSoundpipeDSPBase {
private:
    ParameterRamper balanceRamp;

public:
    AKDryWetMixerDSP() {
        inputBufferLists.resize(2);
        parameters[AKDryWetMixerParameterBalance] = &balanceRamp;
        bCanProcessInPlace = true;
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {
        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            int frameOffset = int(frameIndex + bufferOffset);

            float balance = balanceRamp.getAndStep();

            for (int channel = 0; channel < channelCount; ++channel) {
                float *dry = (float *)inputBufferLists[0]->mBuffers[channel].mData  + frameOffset;
                float *wet = (float *)inputBufferLists[1]->mBuffers[channel].mData + frameOffset;
                float *out = (float *)outputBufferList->mBuffers[channel].mData + frameOffset;

                if (isStarted) {
                    *out = (1.0f - balance) * *dry + balance * *wet;
                } else {
                    *out = *dry;
                }
            }
        }
    }
};

AK_REGISTER_DSP(AKDryWetMixerDSP)
AK_REGISTER_PARAMETER(AKDryWetMixerParameterBalance)
