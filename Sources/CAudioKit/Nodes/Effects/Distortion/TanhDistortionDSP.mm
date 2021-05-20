// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "SoundpipeDSPBase.h"
#include "ParameterRamper.h"
#include "Soundpipe.h"

enum TanhDistortionParameter : AUParameterAddress {
    TanhDistortionParameterPregain,
    TanhDistortionParameterPostgain,
    TanhDistortionParameterPositiveShapeParameter,
    TanhDistortionParameterNegativeShapeParameter,
};

class TanhDistortionDSP : public SoundpipeDSPBase {
private:
    sp_dist *dist0;
    sp_dist *dist1;
    ParameterRamper pregainRamp;
    ParameterRamper postgainRamp;
    ParameterRamper positiveShapeParameterRamp;
    ParameterRamper negativeShapeParameterRamp;

public:
    TanhDistortionDSP() {
        parameters[TanhDistortionParameterPregain] = &pregainRamp;
        parameters[TanhDistortionParameterPostgain] = &postgainRamp;
        parameters[TanhDistortionParameterPositiveShapeParameter] = &positiveShapeParameterRamp;
        parameters[TanhDistortionParameterNegativeShapeParameter] = &negativeShapeParameterRamp;
    }

    void init(int channelCount, double sampleRate) override {
        SoundpipeDSPBase::init(channelCount, sampleRate);
        sp_dist_create(&dist0);
        sp_dist_init(sp, dist0);
        sp_dist_create(&dist1);
        sp_dist_init(sp, dist1);
    }

    void deinit() override {
        SoundpipeDSPBase::deinit();
        sp_dist_destroy(&dist0);
        sp_dist_destroy(&dist1);
    }

    void reset() override {
        SoundpipeDSPBase::reset();
        if (!isInitialized) return;
        sp_dist_init(sp, dist0);
        sp_dist_init(sp, dist1);
    }

    void process(FrameRange range) override {
        for (int i : range) {

            dist0->pregain = dist1->pregain = pregainRamp.getAndStep();
            dist0->postgain = dist1->postgain = postgainRamp.getAndStep();
            dist0->shape1 = dist1->shape1 = positiveShapeParameterRamp.getAndStep();
            dist0->shape2 = dist1->shape2 = negativeShapeParameterRamp.getAndStep();

            float leftIn = inputSample(0, i);
            float rightIn = inputSample(1, i);

            float &leftOut = outputSample(0, i);
            float &rightOut = outputSample(1, i);

            sp_dist_compute(sp, dist0, &leftIn, &leftOut);
            sp_dist_compute(sp, dist1, &rightIn, &rightOut);
        }
    }
};

AK_REGISTER_DSP(TanhDistortionDSP, "dist")
AK_REGISTER_PARAMETER(TanhDistortionParameterPregain)
AK_REGISTER_PARAMETER(TanhDistortionParameterPostgain)
AK_REGISTER_PARAMETER(TanhDistortionParameterPositiveShapeParameter)
AK_REGISTER_PARAMETER(TanhDistortionParameterNegativeShapeParameter)
