// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "SoundpipeDSPBase.h"
#include "ParameterRamper.h"
#include "Soundpipe.h"

enum CombFilterReverbParameter : AUParameterAddress {
    CombFilterReverbParameterReverbDuration,
};

class CombFilterReverbDSP : public SoundpipeDSPBase {
private:
    sp_comb *comb0;
    sp_comb *comb1;
    float loopDuration = 0.1;
    ParameterRamper reverbDurationRamp;

public:
    CombFilterReverbDSP() {
        parameters[CombFilterReverbParameterReverbDuration] = &reverbDurationRamp;
    }

    void setLoopDuration(float duration) {
        loopDuration = duration;
        reset();
    }

    void init(int channelCount, double sampleRate) override {
        SoundpipeDSPBase::init(channelCount, sampleRate);
        sp_comb_create(&comb0);
        sp_comb_init(sp, comb0, loopDuration);
        sp_comb_create(&comb1);
        sp_comb_init(sp, comb1, loopDuration);
    }

    void deinit() override {
        SoundpipeDSPBase::deinit();
        sp_comb_destroy(&comb0);
        sp_comb_destroy(&comb1);
    }

    void reset() override {
        SoundpipeDSPBase::reset();
        if (!isInitialized) return;
        sp_comb_init(sp, comb0, loopDuration);
        sp_comb_init(sp, comb1, loopDuration);
    }

    void process(FrameRange range) override {
        for (int i : range) {

            comb0->revtime = comb1->revtime = reverbDurationRamp.getAndStep();

            float leftIn = inputSample(0, i);
            float rightIn = inputSample(1, i);

            float &leftOut = outputSample(0, i);
            float &rightOut = outputSample(1, i);

            sp_comb_compute(sp, comb0, &leftIn, &leftOut);
            sp_comb_compute(sp, comb1, &rightIn, &rightOut);
        }
    }
};

AK_API void akCombFilterReverbSetLoopDuration(DSPRef dspRef, float duration) {
    auto dsp = dynamic_cast<CombFilterReverbDSP *>(dspRef);
    assert(dsp);
    dsp->setLoopDuration(duration);
}

AK_REGISTER_DSP(CombFilterReverbDSP, "comb")
AK_REGISTER_PARAMETER(CombFilterReverbParameterReverbDuration)
