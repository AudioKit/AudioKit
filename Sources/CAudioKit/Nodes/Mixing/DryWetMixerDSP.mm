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

    void process(FrameRange range) override {
        for (int i : range) {

            float balance = balanceRamp.getAndStep();

            for (int channel = 0; channel < channelCount; ++channel) {
                float dry = inputSample(channel, i);
                float wet = input2Sample(channel, i);
                outputSample(channel, i) =  (1.0f - balance) * dry + balance * wet;
            }

        }
    }
};

AK_REGISTER_DSP(DryWetMixerDSP, "dwmx")
AK_REGISTER_PARAMETER(DryWetMixerParameterBalance)
