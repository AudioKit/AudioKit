// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "SoundpipeDSPBase.h"
#include "ParameterRamper.h"
#include "Soundpipe.h"

enum MoogLadderParameter : AUParameterAddress {
    MoogLadderParameterCutoffFrequency,
    MoogLadderParameterResonance,
};

class MoogLadderDSP : public SoundpipeDSPBase {
private:
    sp_moogladder *moogladder0;
    sp_moogladder *moogladder1;
    ParameterRamper cutoffFrequencyRamp;
    ParameterRamper resonanceRamp;

public:
    MoogLadderDSP() {
        parameters[MoogLadderParameterCutoffFrequency] = &cutoffFrequencyRamp;
        parameters[MoogLadderParameterResonance] = &resonanceRamp;
    }

    void init(int channelCount, double sampleRate) override {
        SoundpipeDSPBase::init(channelCount, sampleRate);
        sp_moogladder_create(&moogladder0);
        sp_moogladder_init(sp, moogladder0);
        sp_moogladder_create(&moogladder1);
        sp_moogladder_init(sp, moogladder1);
    }

    void deinit() override {
        SoundpipeDSPBase::deinit();
        sp_moogladder_destroy(&moogladder0);
        sp_moogladder_destroy(&moogladder1);
    }

    void reset() override {
        SoundpipeDSPBase::reset();
        if (!isInitialized) return;
        sp_moogladder_init(sp, moogladder0);
        sp_moogladder_init(sp, moogladder1);
    }

    void process(FrameRange range) override {
        for (int i : range) {

            moogladder0->freq = moogladder1->freq = cutoffFrequencyRamp.getAndStep();
            moogladder0->res = moogladder1->res = resonanceRamp.getAndStep();

            float leftIn = inputSample(0, i);
            float rightIn = inputSample(1, i);

            float &leftOut = outputSample(0, i);
            float &rightOut = outputSample(1, i);

            sp_moogladder_compute(sp, moogladder0, &leftIn, &leftOut);
            sp_moogladder_compute(sp, moogladder1, &rightIn, &rightOut);
        }
    }
};

AK_REGISTER_DSP(MoogLadderDSP, "mgld")
AK_REGISTER_PARAMETER(MoogLadderParameterCutoffFrequency)
AK_REGISTER_PARAMETER(MoogLadderParameterResonance)
