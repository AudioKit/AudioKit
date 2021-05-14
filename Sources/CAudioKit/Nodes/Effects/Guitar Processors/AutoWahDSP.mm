// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "SoundpipeDSPBase.h"
#include "ParameterRamper.h"
#include "soundpipe.h"

enum AutoWahParameter : AUParameterAddress {
    AutoWahParameterWah,
    AutoWahParameterMix,
    AutoWahParameterAmplitude,
};

class AutoWahDSP : public SoundpipeDSPBase {
private:
    sp_autowah *autowah0;
    sp_autowah *autowah1;
    ParameterRamper wahRamp;
    ParameterRamper mixRamp;
    ParameterRamper amplitudeRamp;

public:
    AutoWahDSP() {
        parameters[AutoWahParameterWah] = &wahRamp;
        parameters[AutoWahParameterMix] = &mixRamp;
        parameters[AutoWahParameterAmplitude] = &amplitudeRamp;
    }

    void init(int channelCount, double sampleRate) override {
        SoundpipeDSPBase::init(channelCount, sampleRate);
        sp_autowah_create(&autowah0);
        sp_autowah_init(sp, autowah0);
        sp_autowah_create(&autowah1);
        sp_autowah_init(sp, autowah1);
    }

    void deinit() override {
        SoundpipeDSPBase::deinit();
        sp_autowah_destroy(&autowah0);
        sp_autowah_destroy(&autowah1);
    }

    void reset() override {
        SoundpipeDSPBase::reset();
        if (!isInitialized) return;
        sp_autowah_init(sp, autowah0);
        sp_autowah_init(sp, autowah1);
    }

    void process2(FrameRange range) override {
        for (int i : range) {

            float wah = wahRamp.getAndStep();
            *autowah0->wah = wah;
            *autowah1->wah = wah;

            float mix = mixRamp.getAndStep() * 100.f;
            *autowah0->mix = mix;
            *autowah1->mix = mix;

            float amplitude = amplitudeRamp.getAndStep();
            *autowah0->level = amplitude;
            *autowah1->level = amplitude;

            float leftIn = inputSample(0, i);
            float rightIn = inputSample(1, i);

            float &leftOut = outputSample(0, i);
            float &rightOut = outputSample(1, i);

            sp_autowah_compute(sp, autowah0, &leftIn, &leftOut);
            sp_autowah_compute(sp, autowah1, &rightIn, &rightOut);
        }
    }
};

AK_REGISTER_DSP(AutoWahDSP, "awah")
AK_REGISTER_PARAMETER(AutoWahParameterWah)
AK_REGISTER_PARAMETER(AutoWahParameterMix)
AK_REGISTER_PARAMETER(AutoWahParameterAmplitude)
