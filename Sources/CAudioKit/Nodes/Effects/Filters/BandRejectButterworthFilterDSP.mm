// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "SoundpipeDSPBase.h"
#include "ParameterRamper.h"
#include "Soundpipe.h"

enum BandRejectButterworthFilterParameter : AUParameterAddress {
    BandRejectButterworthFilterParameterCenterFrequency,
    BandRejectButterworthFilterParameterBandwidth,
};

class BandRejectButterworthFilterDSP : public SoundpipeDSPBase {
private:
    sp_butbr *butbr0;
    sp_butbr *butbr1;
    ParameterRamper centerFrequencyRamp;
    ParameterRamper bandwidthRamp;

public:
    BandRejectButterworthFilterDSP() {
        parameters[BandRejectButterworthFilterParameterCenterFrequency] = &centerFrequencyRamp;
        parameters[BandRejectButterworthFilterParameterBandwidth] = &bandwidthRamp;
    }

    void init(int channelCount, double sampleRate) override {
        SoundpipeDSPBase::init(channelCount, sampleRate);
        sp_butbr_create(&butbr0);
        sp_butbr_init(sp, butbr0);
        sp_butbr_create(&butbr1);
        sp_butbr_init(sp, butbr1);
    }

    void deinit() override {
        SoundpipeDSPBase::deinit();
        sp_butbr_destroy(&butbr0);
        sp_butbr_destroy(&butbr1);
    }

    void reset() override {
        SoundpipeDSPBase::reset();
        if (!isInitialized) return;
        sp_butbr_init(sp, butbr0);
        sp_butbr_init(sp, butbr1);
    }

    void process(FrameRange range) override {
        for (int i : range) {

            butbr0->freq = butbr1->freq = centerFrequencyRamp.getAndStep();
            butbr0->bw = butbr1->bw = bandwidthRamp.getAndStep();

            float leftIn = inputSample(0, i);
            float rightIn = inputSample(1, i);

            float &leftOut = outputSample(0, i);
            float &rightOut = outputSample(1, i);

            sp_butbr_compute(sp, butbr0, &leftIn, &leftOut);
            sp_butbr_compute(sp, butbr1, &rightIn, &rightOut);
        }
    }
};

AK_REGISTER_DSP(BandRejectButterworthFilterDSP, "btbr")
AK_REGISTER_PARAMETER(BandRejectButterworthFilterParameterCenterFrequency)
AK_REGISTER_PARAMETER(BandRejectButterworthFilterParameterBandwidth)
