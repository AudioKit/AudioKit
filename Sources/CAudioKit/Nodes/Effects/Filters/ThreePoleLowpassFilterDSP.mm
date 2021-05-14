// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "SoundpipeDSPBase.h"
#include "ParameterRamper.h"
#include "soundpipe.h"

enum ThreePoleLowpassFilterParameter : AUParameterAddress {
    ThreePoleLowpassFilterParameterDistortion,
    ThreePoleLowpassFilterParameterCutoffFrequency,
    ThreePoleLowpassFilterParameterResonance,
};

class ThreePoleLowpassFilterDSP : public SoundpipeDSPBase {
private:
    sp_lpf18 *lpf180;
    sp_lpf18 *lpf181;
    ParameterRamper distortionRamp;
    ParameterRamper cutoffFrequencyRamp;
    ParameterRamper resonanceRamp;

public:
    ThreePoleLowpassFilterDSP() {
        parameters[ThreePoleLowpassFilterParameterDistortion] = &distortionRamp;
        parameters[ThreePoleLowpassFilterParameterCutoffFrequency] = &cutoffFrequencyRamp;
        parameters[ThreePoleLowpassFilterParameterResonance] = &resonanceRamp;
    }

    void init(int channelCount, double sampleRate) override {
        SoundpipeDSPBase::init(channelCount, sampleRate);
        sp_lpf18_create(&lpf180);
        sp_lpf18_init(sp, lpf180);
        sp_lpf18_create(&lpf181);
        sp_lpf18_init(sp, lpf181);
    }

    void deinit() override {
        SoundpipeDSPBase::deinit();
        sp_lpf18_destroy(&lpf180);
        sp_lpf18_destroy(&lpf181);
    }

    void reset() override {
        SoundpipeDSPBase::reset();
        if (!isInitialized) return;
        sp_lpf18_init(sp, lpf180);
        sp_lpf18_init(sp, lpf181);
    }

    void process2(FrameRange range) override {
        for (int i : range) {

            float distortion = distortionRamp.getAndStep();
            lpf180->dist = distortion;
            lpf181->dist = distortion;

            float cutoffFrequency = cutoffFrequencyRamp.getAndStep();
            lpf180->cutoff = cutoffFrequency;
            lpf181->cutoff = cutoffFrequency;

            float resonance = resonanceRamp.getAndStep();
            lpf180->res = resonance;
            lpf181->res = resonance;

            float leftIn = inputSample(0, i);
            float rightIn = inputSample(1, i);

            float &leftOut = outputSample(0, i);
            float &rightOut = outputSample(1, i);

            sp_lpf18_compute(sp, lpf180, &leftIn, &leftOut);
            sp_lpf18_compute(sp, lpf181, &rightIn, &rightOut);
        }
    }
};

AK_REGISTER_DSP(ThreePoleLowpassFilterDSP, "lp18")
AK_REGISTER_PARAMETER(ThreePoleLowpassFilterParameterDistortion)
AK_REGISTER_PARAMETER(ThreePoleLowpassFilterParameterCutoffFrequency)
AK_REGISTER_PARAMETER(ThreePoleLowpassFilterParameterResonance)
