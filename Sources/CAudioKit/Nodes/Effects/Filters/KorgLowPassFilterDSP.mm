// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "SoundpipeDSPBase.h"
#include "ParameterRamper.h"
#include "Soundpipe.h"

enum KorgLowPassFilterParameter : AUParameterAddress {
    KorgLowPassFilterParameterCutoffFrequency,
    KorgLowPassFilterParameterResonance,
    KorgLowPassFilterParameterSaturation,
};

class KorgLowPassFilterDSP : public SoundpipeDSPBase {
private:
    sp_wpkorg35 *wpkorg350;
    sp_wpkorg35 *wpkorg351;
    ParameterRamper cutoffFrequencyRamp;
    ParameterRamper resonanceRamp;
    ParameterRamper saturationRamp;

public:
    KorgLowPassFilterDSP() {
        parameters[KorgLowPassFilterParameterCutoffFrequency] = &cutoffFrequencyRamp;
        parameters[KorgLowPassFilterParameterResonance] = &resonanceRamp;
        parameters[KorgLowPassFilterParameterSaturation] = &saturationRamp;
    }

    void init(int channelCount, double sampleRate) override {
        SoundpipeDSPBase::init(channelCount, sampleRate);
        sp_wpkorg35_create(&wpkorg350);
        sp_wpkorg35_init(sp, wpkorg350);
        sp_wpkorg35_create(&wpkorg351);
        sp_wpkorg35_init(sp, wpkorg351);
    }

    void deinit() override {
        SoundpipeDSPBase::deinit();
        sp_wpkorg35_destroy(&wpkorg350);
        sp_wpkorg35_destroy(&wpkorg351);
    }

    void reset() override {
        SoundpipeDSPBase::reset();
        if (!isInitialized) return;
        sp_wpkorg35_init(sp, wpkorg350);
        sp_wpkorg35_init(sp, wpkorg351);
    }

    void process(FrameRange range) override {
        for (int i : range) {

            wpkorg350->cutoff = wpkorg351->cutoff = cutoffFrequencyRamp.getAndStep() - 0.0001f;
            wpkorg350->res = wpkorg351->res = resonanceRamp.getAndStep();
            wpkorg350->saturation = wpkorg351->saturation = saturationRamp.getAndStep();

            float leftIn = inputSample(0, i);
            float rightIn = inputSample(1, i);

            float &leftOut = outputSample(0, i);
            float &rightOut = outputSample(1, i);

            sp_wpkorg35_compute(sp, wpkorg350, &leftIn, &leftOut);
            sp_wpkorg35_compute(sp, wpkorg351, &rightIn, &rightOut);
        }
    }
};

AK_REGISTER_DSP(KorgLowPassFilterDSP, "klpf")
AK_REGISTER_PARAMETER(KorgLowPassFilterParameterCutoffFrequency)
AK_REGISTER_PARAMETER(KorgLowPassFilterParameterResonance)
AK_REGISTER_PARAMETER(KorgLowPassFilterParameterSaturation)
