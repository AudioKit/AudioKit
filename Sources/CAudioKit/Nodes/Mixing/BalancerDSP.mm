// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "SoundpipeDSPBase.h"
#include "ParameterRamper.h"
#include "Soundpipe.h"

class BalancerDSP : public SoundpipeDSPBase {
private:
    sp_bal *bal;

public:
    BalancerDSP() {
        inputBufferLists.resize(2);
    }

    void init(int channelCount, double sampleRate) override {
        SoundpipeDSPBase::init(channelCount, sampleRate);

        sp_bal_create(&bal);
        sp_bal_init(sp, bal);
    }

    void deinit() override {
        SoundpipeDSPBase::deinit();
        sp_bal_destroy(&bal);
    }

    void reset() override {
        SoundpipeDSPBase::reset();
        if (isInitialized) sp_bal_init(sp, bal);
    }

    void process(FrameRange range) override {
        for (int i : range) {

            for (int channel = 0; channel < channelCount; ++channel) {
                float in = inputSample(channel, i);
                float comp = input2Sample(channel, i);
                sp_bal_compute(sp, bal, &in, &comp, &outputSample(channel, i));
            }
        }
    }
};

AK_REGISTER_DSP(BalancerDSP, "blnc")
