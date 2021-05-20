// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "SoundpipeDSPBase.h"
#include "ParameterRamper.h"
#include "Soundpipe.h"

enum LowPassButterworthFilterParameter : AUParameterAddress {
    LowPassButterworthFilterParameterCutoffFrequency,
};

class LowPassButterworthFilterDSP : public SoundpipeDSPBase {
private:
    sp_butlp *butlp0;
    sp_butlp *butlp1;
    ParameterRamper cutoffFrequencyRamp;

public:
    LowPassButterworthFilterDSP() {
        parameters[LowPassButterworthFilterParameterCutoffFrequency] = &cutoffFrequencyRamp;
    }

    void init(int channelCount, double sampleRate) override {
        SoundpipeDSPBase::init(channelCount, sampleRate);
        sp_butlp_create(&butlp0);
        sp_butlp_init(sp, butlp0);
        sp_butlp_create(&butlp1);
        sp_butlp_init(sp, butlp1);
    }

    void deinit() override {
        SoundpipeDSPBase::deinit();
        sp_butlp_destroy(&butlp0);
        sp_butlp_destroy(&butlp1);
    }

    void reset() override {
        SoundpipeDSPBase::reset();
        if (!isInitialized) return;
        sp_butlp_init(sp, butlp0);
        sp_butlp_init(sp, butlp1);
    }

    void process(FrameRange range) override {
        for (int i : range) {

            butlp0->freq = butlp1->freq = cutoffFrequencyRamp.getAndStep();

            float leftIn = inputSample(0, i);
            float rightIn = inputSample(1, i);

            float &leftOut = outputSample(0, i);
            float &rightOut = outputSample(1, i);

            sp_butlp_compute(sp, butlp0, &leftIn, &leftOut);
            sp_butlp_compute(sp, butlp1, &rightIn, &rightOut);
        }
    }
};

AK_REGISTER_DSP(LowPassButterworthFilterDSP, "btlp")
AK_REGISTER_PARAMETER(LowPassButterworthFilterParameterCutoffFrequency)
