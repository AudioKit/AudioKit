// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "SoundpipeDSPBase.h"
#include "ParameterRamper.h"
#include "Soundpipe.h"

enum FormantFilterParameter : AUParameterAddress {
    FormantFilterParameterCenterFrequency,
    FormantFilterParameterAttackDuration,
    FormantFilterParameterDecayDuration,
};

class FormantFilterDSP : public SoundpipeDSPBase {
private:
    sp_fofilt *fofilt0;
    sp_fofilt *fofilt1;
    ParameterRamper centerFrequencyRamp;
    ParameterRamper attackDurationRamp;
    ParameterRamper decayDurationRamp;

public:
    FormantFilterDSP() {
        parameters[FormantFilterParameterCenterFrequency] = &centerFrequencyRamp;
        parameters[FormantFilterParameterAttackDuration] = &attackDurationRamp;
        parameters[FormantFilterParameterDecayDuration] = &decayDurationRamp;
    }

    void init(int channelCount, double sampleRate) override {
        SoundpipeDSPBase::init(channelCount, sampleRate);
        sp_fofilt_create(&fofilt0);
        sp_fofilt_init(sp, fofilt0);
        sp_fofilt_create(&fofilt1);
        sp_fofilt_init(sp, fofilt1);
    }

    void deinit() override {
        SoundpipeDSPBase::deinit();
        sp_fofilt_destroy(&fofilt0);
        sp_fofilt_destroy(&fofilt1);
    }

    void reset() override {
        SoundpipeDSPBase::reset();
        if (!isInitialized) return;
        sp_fofilt_init(sp, fofilt0);
        sp_fofilt_init(sp, fofilt1);
    }

    void process(FrameRange range) override {
        for (int i : range) {

            fofilt0->freq = fofilt1->freq = centerFrequencyRamp.getAndStep();
            fofilt0->atk = fofilt1->atk = attackDurationRamp.getAndStep();
            fofilt0->dec = fofilt1->dec = decayDurationRamp.getAndStep();

            float leftIn = inputSample(0, i);
            float rightIn = inputSample(1, i);

            float &leftOut = outputSample(0, i);
            float &rightOut = outputSample(1, i);

            sp_fofilt_compute(sp, fofilt0, &leftIn, &leftOut);
            sp_fofilt_compute(sp, fofilt1, &rightIn, &rightOut);
        }
    }
};

AK_REGISTER_DSP(FormantFilterDSP, "fofi")
AK_REGISTER_PARAMETER(FormantFilterParameterCenterFrequency)
AK_REGISTER_PARAMETER(FormantFilterParameterAttackDuration)
AK_REGISTER_PARAMETER(FormantFilterParameterDecayDuration)
