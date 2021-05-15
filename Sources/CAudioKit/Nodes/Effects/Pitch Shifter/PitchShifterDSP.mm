// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "SoundpipeDSPBase.h"
#include "ParameterRamper.h"
#include "soundpipe.h"

enum PitchShifterParameter : AUParameterAddress {
    PitchShifterParameterShift,
    PitchShifterParameterWindowSize,
    PitchShifterParameterCrossfade,
};

class PitchShifterDSP : public SoundpipeDSPBase {
private:
    sp_pshift *pshift0;
    sp_pshift *pshift1;
    ParameterRamper shiftRamp;
    ParameterRamper windowSizeRamp;
    ParameterRamper crossfadeRamp;

public:
    PitchShifterDSP() {
        parameters[PitchShifterParameterShift] = &shiftRamp;
        parameters[PitchShifterParameterWindowSize] = &windowSizeRamp;
        parameters[PitchShifterParameterCrossfade] = &crossfadeRamp;
    }

    void init(int channelCount, double sampleRate) override {
        SoundpipeDSPBase::init(channelCount, sampleRate);
        sp_pshift_create(&pshift0);
        sp_pshift_init(sp, pshift0);
        sp_pshift_create(&pshift1);
        sp_pshift_init(sp, pshift1);
    }

    void deinit() override {
        SoundpipeDSPBase::deinit();
        sp_pshift_destroy(&pshift0);
        sp_pshift_destroy(&pshift1);
    }

    void reset() override {
        SoundpipeDSPBase::reset();
        if (!isInitialized) return;
        sp_pshift_init(sp, pshift0);
        sp_pshift_init(sp, pshift1);
    }

    void process2(FrameRange range) override {
        for (int i : range) {

            float shift = shiftRamp.getAndStep();
            float windowSize = windowSizeRamp.getAndStep();
            float crossfade = crossfadeRamp.getAndStep();

            *pshift0->shift = *pshift1->shift = shift;
            *pshift0->window = *pshift1->window = windowSize;
            *pshift0->xfade = *pshift1->xfade = crossfade;

            float leftIn = inputSample(0, i);
            float rightIn = inputSample(1, i);

            float &leftOut = outputSample(0, i);
            float &rightOut = outputSample(1, i);

            sp_pshift_compute(sp, pshift0, &leftIn, &leftOut);
            sp_pshift_compute(sp, pshift1, &rightIn, &rightOut);
        }
    }
};

AK_REGISTER_DSP(PitchShifterDSP, "pshf")
AK_REGISTER_PARAMETER(PitchShifterParameterShift)
AK_REGISTER_PARAMETER(PitchShifterParameterWindowSize)
AK_REGISTER_PARAMETER(PitchShifterParameterCrossfade)
