// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "SoundpipeDSPBase.h"
#include "ParameterRamper.h"
#include "Soundpipe.h"

enum LowShelfParametricEqualizerFilterParameter : AUParameterAddress {
    LowShelfParametricEqualizerFilterParameterCornerFrequency,
    LowShelfParametricEqualizerFilterParameterGain,
    LowShelfParametricEqualizerFilterParameterQ,
};

class LowShelfParametricEqualizerFilterDSP : public SoundpipeDSPBase {
private:
    sp_pareq *pareq0;
    sp_pareq *pareq1;
    ParameterRamper cornerFrequencyRamp;
    ParameterRamper gainRamp;
    ParameterRamper qRamp;

public:
    LowShelfParametricEqualizerFilterDSP() {
        parameters[LowShelfParametricEqualizerFilterParameterCornerFrequency] = &cornerFrequencyRamp;
        parameters[LowShelfParametricEqualizerFilterParameterGain] = &gainRamp;
        parameters[LowShelfParametricEqualizerFilterParameterQ] = &qRamp;
    }

    void init(int channelCount, double sampleRate) override {
        SoundpipeDSPBase::init(channelCount, sampleRate);
        sp_pareq_create(&pareq0);
        sp_pareq_init(sp, pareq0);
        sp_pareq_create(&pareq1);
        sp_pareq_init(sp, pareq1);
        pareq0->mode = pareq1->mode = 1;
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
        pareq0->mode = pareq1->mode = 1;
    }

    void process(FrameRange range) override {
        for (int i : range) {

            pareq0->fc = pareq1->fc = cornerFrequencyRamp.getAndStep();
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

AK_REGISTER_DSP(LowShelfParametricEqualizerFilterDSP, "peq1")
AK_REGISTER_PARAMETER(LowShelfParametricEqualizerFilterParameterCornerFrequency)
AK_REGISTER_PARAMETER(LowShelfParametricEqualizerFilterParameterGain)
AK_REGISTER_PARAMETER(LowShelfParametricEqualizerFilterParameterQ)
