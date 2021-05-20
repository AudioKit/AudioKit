// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "SoundpipeDSPBase.h"
#include "ParameterRamper.h"
#include "Soundpipe.h"

enum ToneComplementFilterParameter : AUParameterAddress {
    ToneComplementFilterParameterHalfPowerPoint,
};

class ToneComplementFilterDSP : public SoundpipeDSPBase {
private:
    sp_atone *atone0;
    sp_atone *atone1;
    ParameterRamper halfPowerPointRamp;

public:
    ToneComplementFilterDSP() : SoundpipeDSPBase(1, false) {
        parameters[ToneComplementFilterParameterHalfPowerPoint] = &halfPowerPointRamp;
    }

    void init(int channelCount, double sampleRate) override {
        SoundpipeDSPBase::init(channelCount, sampleRate);
        sp_atone_create(&atone0);
        sp_atone_init(sp, atone0);
        sp_atone_create(&atone1);
        sp_atone_init(sp, atone1);
    }

    void deinit() override {
        SoundpipeDSPBase::deinit();
        sp_atone_destroy(&atone0);
        sp_atone_destroy(&atone1);
    }

    void reset() override {
        SoundpipeDSPBase::reset();
        if (!isInitialized) return;
        sp_atone_init(sp, atone0);
        sp_atone_init(sp, atone1);
    }

    void process(FrameRange range) override {
        for (int i : range) {

            atone0->hp = atone1->hp = halfPowerPointRamp.getAndStep();

            float leftIn = inputSample(0, i);
            float rightIn = inputSample(1, i);

            float &leftOut = outputSample(0, i);
            float &rightOut = outputSample(1, i);

            sp_atone_compute(sp, atone0, &leftIn, &leftOut);
            sp_atone_compute(sp, atone1, &rightIn, &rightOut);
        }
    }
};

AK_REGISTER_DSP(ToneComplementFilterDSP, "aton")
AK_REGISTER_PARAMETER(ToneComplementFilterParameterHalfPowerPoint)
