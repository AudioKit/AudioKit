// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "SoundpipeDSPBase.h"
#include "ParameterRamper.h"
#include "Soundpipe.h"

enum CostelloReverbParameter : AUParameterAddress {
    CostelloReverbParameterFeedback,
    CostelloReverbParameterCutoffFrequency,
};

class CostelloReverbDSP : public SoundpipeDSPBase {
private:
    sp_revsc *revsc;
    ParameterRamper feedbackRamp;
    ParameterRamper cutoffFrequencyRamp;

public:
    CostelloReverbDSP() {
        parameters[CostelloReverbParameterFeedback] = &feedbackRamp;
        parameters[CostelloReverbParameterCutoffFrequency] = &cutoffFrequencyRamp;
    }

    void init(int channelCount, double sampleRate) override {
        SoundpipeDSPBase::init(channelCount, sampleRate);
        sp_revsc_create(&revsc);
        sp_revsc_init(sp, revsc);
    }

    void deinit() override {
        SoundpipeDSPBase::deinit();
        sp_revsc_destroy(&revsc);
    }

    void reset() override {
        SoundpipeDSPBase::reset();
        if (!isInitialized) return;
        sp_revsc_init(sp, revsc);
    }

    void process(FrameRange range) override {
        for (int i : range) {

            revsc->feedback = feedbackRamp.getAndStep();
            revsc->lpfreq = cutoffFrequencyRamp.getAndStep();

            float leftIn = inputSample(0, i);
            float rightIn = inputSample(1, i);

            float &leftOut = outputSample(0, i);
            float &rightOut = outputSample(1, i);
            
            sp_revsc_compute(sp, revsc, &leftIn, &rightIn, &leftOut, &rightOut);
        }
    }
};

AK_REGISTER_DSP(CostelloReverbDSP, "rvsc")
AK_REGISTER_PARAMETER(CostelloReverbParameterFeedback)
AK_REGISTER_PARAMETER(CostelloReverbParameterCutoffFrequency)
