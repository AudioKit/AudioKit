// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "SoundpipeDSPBase.h"
#include "ParameterRamper.h"
#include "Soundpipe.h"

enum FlatFrequencyResponseReverbParameter : AUParameterAddress {
    FlatFrequencyResponseReverbParameterReverbDuration,
};

class FlatFrequencyResponseReverbDSP : public SoundpipeDSPBase {
private:
    sp_allpass *allpass0;
    sp_allpass *allpass1;
    float loopDuration = 0.1;
    ParameterRamper reverbDurationRamp;

public:
    FlatFrequencyResponseReverbDSP() {
        parameters[FlatFrequencyResponseReverbParameterReverbDuration] = &reverbDurationRamp;
    }

    void setLoopDuration(float duration) {
        loopDuration = duration;
        reset();
    }

    void init(int channelCount, double sampleRate) override {
        SoundpipeDSPBase::init(channelCount, sampleRate);
        sp_allpass_create(&allpass0);
        sp_allpass_init(sp, allpass0, loopDuration);
        sp_allpass_create(&allpass1);
        sp_allpass_init(sp, allpass1, loopDuration);
    }

    void deinit() override {
        SoundpipeDSPBase::deinit();
        sp_allpass_destroy(&allpass0);
        sp_allpass_destroy(&allpass1);
    }

    void reset() override {
        SoundpipeDSPBase::reset();
        if (!isInitialized) return;
        sp_allpass_init(sp, allpass0, loopDuration);
        sp_allpass_init(sp, allpass1, loopDuration);
    }

    void process(FrameRange range) override {
        for (int i : range) {

            allpass0->revtime = allpass1->revtime = reverbDurationRamp.getAndStep();

            float leftIn = inputSample(0, i);
            float rightIn = inputSample(1, i);

            float &leftOut = outputSample(0, i);
            float &rightOut = outputSample(1, i);

            sp_allpass_compute(sp, allpass0, &leftIn, &leftOut);
            sp_allpass_compute(sp, allpass1, &rightIn, &rightOut);
        }
    }
};

AK_API void akFlatFrequencyResponseSetLoopDuration(DSPRef dspRef, float duration) {
    auto dsp = dynamic_cast<FlatFrequencyResponseReverbDSP *>(dspRef);
    assert(dsp);
    dsp->setLoopDuration(duration);
}

AK_REGISTER_DSP(FlatFrequencyResponseReverbDSP, "alps")
AK_REGISTER_PARAMETER(FlatFrequencyResponseReverbParameterReverbDuration)
