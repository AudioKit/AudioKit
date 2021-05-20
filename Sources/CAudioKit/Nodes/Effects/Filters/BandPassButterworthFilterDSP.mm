// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "SoundpipeDSPBase.h"
#include "ParameterRamper.h"
#include "Soundpipe.h"

enum BandPassButterworthFilterParameter : AUParameterAddress {
    BandPassButterworthFilterParameterCenterFrequency,
    BandPassButterworthFilterParameterBandwidth,
};

class BandPassButterworthFilterDSP : public SoundpipeDSPBase {
private:
    sp_butbp *butbp0;
    sp_butbp *butbp1;
    ParameterRamper centerFrequencyRamp;
    ParameterRamper bandwidthRamp;

public:
    BandPassButterworthFilterDSP() {
        parameters[BandPassButterworthFilterParameterCenterFrequency] = &centerFrequencyRamp;
        parameters[BandPassButterworthFilterParameterBandwidth] = &bandwidthRamp;
    }

    void init(int channelCount, double sampleRate) override {
        SoundpipeDSPBase::init(channelCount, sampleRate);
        sp_butbp_create(&butbp0);
        sp_butbp_init(sp, butbp0);
        sp_butbp_create(&butbp1);
        sp_butbp_init(sp, butbp1);
    }

    void deinit() override {
        SoundpipeDSPBase::deinit();
        sp_butbp_destroy(&butbp0);
        sp_butbp_destroy(&butbp1);
    }

    void reset() override {
        SoundpipeDSPBase::reset();
        if (!isInitialized) return;
        sp_butbp_init(sp, butbp0);
        sp_butbp_init(sp, butbp1);
    }

    void process(FrameRange range) override {
        for (int i : range) {

            butbp0->freq = butbp1->freq = centerFrequencyRamp.getAndStep();
            butbp0->bw = butbp1->bw = bandwidthRamp.getAndStep();

            float leftIn = inputSample(0, i);
            float rightIn = inputSample(1, i);

            float &leftOut = outputSample(0, i);
            float &rightOut = outputSample(1, i);

            sp_butbp_compute(sp, butbp0, &leftIn, &leftOut);
            sp_butbp_compute(sp, butbp1, &rightIn, &rightOut);
        }
    }
};

AK_REGISTER_DSP(BandPassButterworthFilterDSP, "btbp")
AK_REGISTER_PARAMETER(BandPassButterworthFilterParameterCenterFrequency)
AK_REGISTER_PARAMETER(BandPassButterworthFilterParameterBandwidth)
