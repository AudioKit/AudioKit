// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "SoundpipeDSPBase.h"
#include "ParameterRamper.h"
#include "soundpipe.h"

enum HighShelfParametricEqualizerFilterParameter : AUParameterAddress {
    HighShelfParametricEqualizerFilterParameterCenterFrequency,
    HighShelfParametricEqualizerFilterParameterGain,
    HighShelfParametricEqualizerFilterParameterQ,
};

class HighShelfParametricEqualizerFilterDSP : public SoundpipeDSPBase {
private:
    sp_pareq *pareq0;
    sp_pareq *pareq1;
    ParameterRamper centerFrequencyRamp;
    ParameterRamper gainRamp;
    ParameterRamper qRamp;

public:
    HighShelfParametricEqualizerFilterDSP() {
        parameters[HighShelfParametricEqualizerFilterParameterCenterFrequency] = &centerFrequencyRamp;
        parameters[HighShelfParametricEqualizerFilterParameterGain] = &gainRamp;
        parameters[HighShelfParametricEqualizerFilterParameterQ] = &qRamp;
    }

    void init(int channelCount, double sampleRate) override {
        SoundpipeDSPBase::init(channelCount, sampleRate);
        sp_pareq_create(&pareq0);
        sp_pareq_init(sp, pareq0);
        sp_pareq_create(&pareq1);
        sp_pareq_init(sp, pareq1);
        pareq0->mode = pareq1->mode = 2;
    }

    void deinit() override {
        SoundpipeDSPBase::deinit();
        sp_pareq_destroy(&pareq0);
        sp_pareq_destroy(&pareq1);
    }

    void reset() override {
        SoundpipeDSPBase::reset();
        if (!isInitialized) return;
        sp_pareq_init(sp, pareq0);
        sp_pareq_init(sp, pareq1);
        pareq0->mode = pareq1->mode = 2;
    }

    void process2(FrameRange range) override {
        for (int i : range) {

            pareq0->fc = pareq1->fc = centerFrequencyRamp.getAndStep();
            pareq0->v = pareq1->v = gainRamp.getAndStep();
            pareq0->q = pareq1->q = qRamp.getAndStep();

            float leftIn = inputSample(0, i);
            float rightIn = inputSample(1, i);

            float &leftOut = outputSample(0, i);
            float &rightOut = outputSample(1, i);

            sp_pareq_compute(sp, pareq0, &leftIn, &leftOut);
            sp_pareq_compute(sp, pareq1, &rightIn, &rightOut);
        }
    }
};

AK_REGISTER_DSP(HighShelfParametricEqualizerFilterDSP, "peq2")
AK_REGISTER_PARAMETER(HighShelfParametricEqualizerFilterParameterCenterFrequency)
AK_REGISTER_PARAMETER(HighShelfParametricEqualizerFilterParameterGain)
AK_REGISTER_PARAMETER(HighShelfParametricEqualizerFilterParameterQ)
