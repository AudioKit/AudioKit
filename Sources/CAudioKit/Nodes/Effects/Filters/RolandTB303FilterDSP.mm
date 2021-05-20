// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "SoundpipeDSPBase.h"
#include "ParameterRamper.h"
#include "Soundpipe.h"

enum RolandTB303FilterParameter : AUParameterAddress {
    RolandTB303FilterParameterCutoffFrequency,
    RolandTB303FilterParameterResonance,
    RolandTB303FilterParameterDistortion,
    RolandTB303FilterParameterResonanceAsymmetry,
};

class RolandTB303FilterDSP : public SoundpipeDSPBase {
private:
    sp_tbvcf *tbvcf0;
    sp_tbvcf *tbvcf1;
    ParameterRamper cutoffFrequencyRamp;
    ParameterRamper resonanceRamp;
    ParameterRamper distortionRamp;
    ParameterRamper resonanceAsymmetryRamp;

public:
    RolandTB303FilterDSP() {
        parameters[RolandTB303FilterParameterCutoffFrequency] = &cutoffFrequencyRamp;
        parameters[RolandTB303FilterParameterResonance] = &resonanceRamp;
        parameters[RolandTB303FilterParameterDistortion] = &distortionRamp;
        parameters[RolandTB303FilterParameterResonanceAsymmetry] = &resonanceAsymmetryRamp;
    }

    void init(int channelCount, double sampleRate) override {
        SoundpipeDSPBase::init(channelCount, sampleRate);
        sp_tbvcf_create(&tbvcf0);
        sp_tbvcf_init(sp, tbvcf0);
        sp_tbvcf_create(&tbvcf1);
        sp_tbvcf_init(sp, tbvcf1);
    }

    void deinit() override {
        SoundpipeDSPBase::deinit();
        sp_tbvcf_destroy(&tbvcf0);
        sp_tbvcf_destroy(&tbvcf1);
    }

    void reset() override {
        SoundpipeDSPBase::reset();
        if (!isInitialized) return;
        sp_tbvcf_init(sp, tbvcf0);
        sp_tbvcf_init(sp, tbvcf1);
    }

    void process(FrameRange range) override {
        for (int i : range) {

            tbvcf0->fco = tbvcf1->fco = cutoffFrequencyRamp.getAndStep();
            tbvcf0->res = tbvcf1->res = resonanceRamp.getAndStep();
            tbvcf0->dist = tbvcf1->dist = distortionRamp.getAndStep();
            tbvcf0->asym = tbvcf1->asym = resonanceAsymmetryRamp.getAndStep();

            float leftIn = inputSample(0, i);
            float rightIn = inputSample(1, i);

            float &leftOut = outputSample(0, i);
            float &rightOut = outputSample(1, i);

            sp_tbvcf_compute(sp, tbvcf0, &leftIn, &leftOut);
            sp_tbvcf_compute(sp, tbvcf1, &rightIn, &rightOut);
        }
    }
};

AK_REGISTER_DSP(RolandTB303FilterDSP, "tb3f")
AK_REGISTER_PARAMETER(RolandTB303FilterParameterCutoffFrequency)
AK_REGISTER_PARAMETER(RolandTB303FilterParameterResonance)
AK_REGISTER_PARAMETER(RolandTB303FilterParameterDistortion)
AK_REGISTER_PARAMETER(RolandTB303FilterParameterResonanceAsymmetry)
