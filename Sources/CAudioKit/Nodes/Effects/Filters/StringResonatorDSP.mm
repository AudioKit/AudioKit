// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "SoundpipeDSPBase.h"
#include "ParameterRamper.h"
#include "Soundpipe.h"

enum StringResonatorParameter : AUParameterAddress {
    StringResonatorParameterFundamentalFrequency,
    StringResonatorParameterFeedback,
};

class StringResonatorDSP : public SoundpipeDSPBase {
private:
    sp_streson *streson0;
    sp_streson *streson1;
    ParameterRamper fundamentalFrequencyRamp;
    ParameterRamper feedbackRamp;

public:
    StringResonatorDSP() {
        parameters[StringResonatorParameterFundamentalFrequency] = &fundamentalFrequencyRamp;
        parameters[StringResonatorParameterFeedback] = &feedbackRamp;
    }

    void init(int channelCount, double sampleRate) override {
        SoundpipeDSPBase::init(channelCount, sampleRate);
        sp_streson_create(&streson0);
        sp_streson_init(sp, streson0);
        sp_streson_create(&streson1);
        sp_streson_init(sp, streson1);
    }

    void deinit() override {
        SoundpipeDSPBase::deinit();
        sp_streson_destroy(&streson0);
        sp_streson_destroy(&streson1);
    }

    void reset() override {
        SoundpipeDSPBase::reset();
        if (!isInitialized) return;
        sp_streson_init(sp, streson0);
        sp_streson_init(sp, streson1);
    }

    void process(FrameRange range) override {
        for (int i : range) {

            streson0->freq = streson1->freq = fundamentalFrequencyRamp.getAndStep();
            streson0->fdbgain = streson1->fdbgain = feedbackRamp.getAndStep();

            float leftIn = inputSample(0, i);
            float rightIn = inputSample(1, i);

            float &leftOut = outputSample(0, i);
            float &rightOut = outputSample(1, i);

            sp_streson_compute(sp, streson0, &leftIn, &leftOut);
            sp_streson_compute(sp, streson1, &rightIn, &rightOut);
        }
    }
};

AK_REGISTER_DSP(StringResonatorDSP, "stre")
AK_REGISTER_PARAMETER(StringResonatorParameterFundamentalFrequency)
AK_REGISTER_PARAMETER(StringResonatorParameterFeedback)
