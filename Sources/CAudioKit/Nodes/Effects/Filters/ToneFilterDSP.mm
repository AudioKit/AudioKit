// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "SoundpipeDSPBase.h"
#include "ParameterRamper.h"
#include "Soundpipe.h"

enum ToneFilterParameter : AUParameterAddress {
    ToneFilterParameterHalfPowerPoint,
};

class ToneFilterDSP : public SoundpipeDSPBase {
private:
    sp_tone *tone0;
    sp_tone *tone1;
    ParameterRamper halfPowerPointRamp;

public:
    ToneFilterDSP() {
        parameters[ToneFilterParameterHalfPowerPoint] = &halfPowerPointRamp;
    }

    void init(int channelCount, double sampleRate) override {
        SoundpipeDSPBase::init(channelCount, sampleRate);
        sp_tone_create(&tone0);
        sp_tone_init(sp, tone0);
        sp_tone_create(&tone1);
        sp_tone_init(sp, tone1);
    }

    void deinit() override {
        SoundpipeDSPBase::deinit();
        sp_tone_destroy(&tone0);
        sp_tone_destroy(&tone1);
    }

    void reset() override {
        SoundpipeDSPBase::reset();
        if (!isInitialized) return;
        sp_tone_init(sp, tone0);
        sp_tone_init(sp, tone1);
    }

    void process(FrameRange range) override {
        for (int i : range) {

            tone0->hp = tone1->hp = halfPowerPointRamp.getAndStep();

            float leftIn = inputSample(0, i);
            float rightIn = inputSample(1, i);

            float &leftOut = outputSample(0, i);
            float &rightOut = outputSample(1, i);

            sp_tone_compute(sp, tone0, &leftIn, &leftOut);
            sp_tone_compute(sp, tone1, &rightIn, &rightOut);
        }
    }
};

AK_REGISTER_DSP(ToneFilterDSP, "tone")
AK_REGISTER_PARAMETER(ToneFilterParameterHalfPowerPoint)
