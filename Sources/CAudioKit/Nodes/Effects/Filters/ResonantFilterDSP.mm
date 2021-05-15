// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "SoundpipeDSPBase.h"
#include "ParameterRamper.h"
#include "soundpipe.h"

enum ResonantFilterParameter : AUParameterAddress {
    ResonantFilterParameterFrequency,
    ResonantFilterParameterBandwidth,
};

class ResonantFilterDSP : public SoundpipeDSPBase {
private:
    sp_reson *reson0;
    sp_reson *reson1;
    ParameterRamper frequencyRamp;
    ParameterRamper bandwidthRamp;

public:
    ResonantFilterDSP() {
        parameters[ResonantFilterParameterFrequency] = &frequencyRamp;
        parameters[ResonantFilterParameterBandwidth] = &bandwidthRamp;
    }

    void init(int channelCount, double sampleRate) override {
        SoundpipeDSPBase::init(channelCount, sampleRate);
        sp_reson_create(&reson0);
        sp_reson_init(sp, reson0);
        sp_reson_create(&reson1);
        sp_reson_init(sp, reson1);
    }

    void deinit() override {
        SoundpipeDSPBase::deinit();
        sp_reson_destroy(&reson0);
        sp_reson_destroy(&reson1);
    }

    void reset() override {
        SoundpipeDSPBase::reset();
        if (!isInitialized) return;
        sp_reson_init(sp, reson0);
        sp_reson_init(sp, reson1);
    }

    void process2(FrameRange range) override {
        for (int i : range) {

            float frequency = frequencyRamp.getAndStep();
            reson0->freq = reson1->freq = frequency;

            float bandwidth = bandwidthRamp.getAndStep();
            reson0->bw = reson1->bw = bandwidth;

            float leftIn = inputSample(0, i);
            float rightIn = inputSample(1, i);

            float &leftOut = outputSample(0, i);
            float &rightOut = outputSample(1, i);

            sp_reson_compute(sp, reson0, &leftIn, &leftOut);
            sp_reson_compute(sp, reson1, &rightIn, &rightOut);
        }
    }
};

AK_REGISTER_DSP(ResonantFilterDSP, "resn")
AK_REGISTER_PARAMETER(ResonantFilterParameterFrequency)
AK_REGISTER_PARAMETER(ResonantFilterParameterBandwidth)
