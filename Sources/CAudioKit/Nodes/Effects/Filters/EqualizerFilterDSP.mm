// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "SoundpipeDSPBase.h"
#include "ParameterRamper.h"
#include "Soundpipe.h"

enum EqualizerFilterParameter : AUParameterAddress {
    EqualizerFilterParameterCenterFrequency,
    EqualizerFilterParameterBandwidth,
    EqualizerFilterParameterGain,
};

class EqualizerFilterDSP : public SoundpipeDSPBase {
private:
    sp_eqfil *eqfil0;
    sp_eqfil *eqfil1;
    ParameterRamper centerFrequencyRamp;
    ParameterRamper bandwidthRamp;
    ParameterRamper gainRamp;

public:
    EqualizerFilterDSP() {
        parameters[EqualizerFilterParameterCenterFrequency] = &centerFrequencyRamp;
        parameters[EqualizerFilterParameterBandwidth] = &bandwidthRamp;
        parameters[EqualizerFilterParameterGain] = &gainRamp;
    }

    void init(int channelCount, double sampleRate) override {
        SoundpipeDSPBase::init(channelCount, sampleRate);
        sp_eqfil_create(&eqfil0);
        sp_eqfil_init(sp, eqfil0);
        sp_eqfil_create(&eqfil1);
        sp_eqfil_init(sp, eqfil1);
    }

    void deinit() override {
        SoundpipeDSPBase::deinit();
        sp_eqfil_destroy(&eqfil0);
        sp_eqfil_destroy(&eqfil1);
    }

    void reset() override {
        SoundpipeDSPBase::reset();
        if (!isInitialized) return;
        sp_eqfil_init(sp, eqfil0);
        sp_eqfil_init(sp, eqfil1);
    }

    void process(FrameRange range) override {
        for (int i : range) {

            eqfil0->freq = eqfil1->freq = centerFrequencyRamp.getAndStep();
            eqfil0->bw = eqfil1->bw = bandwidthRamp.getAndStep();
            eqfil0->gain = eqfil1->gain = gainRamp.getAndStep();

            float leftIn = inputSample(0, i);
            float rightIn = inputSample(1, i);

            float &leftOut = outputSample(0, i);
            float &rightOut = outputSample(1, i);

            sp_eqfil_compute(sp, eqfil0, &leftIn, &leftOut);
            sp_eqfil_compute(sp, eqfil1, &rightIn, &rightOut);
        }
    }
};

AK_REGISTER_DSP(EqualizerFilterDSP, "eqfl")
AK_REGISTER_PARAMETER(EqualizerFilterParameterCenterFrequency)
AK_REGISTER_PARAMETER(EqualizerFilterParameterBandwidth)
AK_REGISTER_PARAMETER(EqualizerFilterParameterGain)
