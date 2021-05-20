// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "SoundpipeDSPBase.h"
#include "ParameterRamper.h"
#include "Soundpipe.h"

enum HighPassButterworthFilterParameter : AUParameterAddress {
    HighPassButterworthFilterParameterCutoffFrequency,
};

class HighPassButterworthFilterDSP : public SoundpipeDSPBase {
private:
    sp_buthp *buthp0;
    sp_buthp *buthp1;
    ParameterRamper cutoffFrequencyRamp;

public:
    HighPassButterworthFilterDSP() {
        parameters[HighPassButterworthFilterParameterCutoffFrequency] = &cutoffFrequencyRamp;
    }

    void init(int channelCount, double sampleRate) override {
        SoundpipeDSPBase::init(channelCount, sampleRate);
        sp_buthp_create(&buthp0);
        sp_buthp_init(sp, buthp0);
        sp_buthp_create(&buthp1);
        sp_buthp_init(sp, buthp1);
    }

    void deinit() override {
        SoundpipeDSPBase::deinit();
        sp_buthp_destroy(&buthp0);
        sp_buthp_destroy(&buthp1);
    }

    void reset() override {
        SoundpipeDSPBase::reset();
        if (!isInitialized) return;
        sp_buthp_init(sp, buthp0);
        sp_buthp_init(sp, buthp1);
    }

    void process(FrameRange range) override {
        for (int i : range) {

            buthp0->freq = buthp1->freq = cutoffFrequencyRamp.getAndStep();

            float leftIn = inputSample(0, i);
            float rightIn = inputSample(1, i);

            float &leftOut = outputSample(0, i);
            float &rightOut = outputSample(1, i);

            sp_buthp_compute(sp, buthp0, &leftIn, &leftOut);
            sp_buthp_compute(sp, buthp1, &rightIn, &rightOut);
        }
    }
};

AK_REGISTER_DSP(HighPassButterworthFilterDSP, "bthp")
AK_REGISTER_PARAMETER(HighPassButterworthFilterParameterCutoffFrequency)
