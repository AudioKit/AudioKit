// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "SoundpipeDSPBase.h"
#include "ParameterRamper.h"
#include "Soundpipe.h"

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

    void process(FrameRange range) override {
        for (int i : range) {

            lpf180->dist = lpf181->dist = distortionRamp.getAndStep();
            lpf180->cutoff = lpf181->cutoff = cutoffFrequencyRamp.getAndStep();
            lpf180->res = lpf181->res = resonanceRamp.getAndStep();

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
