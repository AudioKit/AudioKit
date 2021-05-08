// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "SoundpipeDSPBase.h"
#include "ParameterRamper.h"

enum DryWetMixerParameter : AUParameterAddress {
    DryWetMixerParameterBalance,
};

class DryWetMixerDSP : public SoundpipeDSPBase {
private:
    ParameterRamper balanceRamp;

public:
    DryWetMixerDSP() {
        inputBufferLists.resize(2);
        parameters[DryWetMixerParameterBalance] = &balanceRamp;
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

AK_REGISTER_DSP(DryWetMixerDSP, "dwmx")
AK_REGISTER_PARAMETER(DryWetMixerParameterBalance)
