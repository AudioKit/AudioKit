// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "SoundpipeDSPBase.h"
#include "ParameterRamper.h"
#include "Soundpipe.h"

enum ModalResonanceFilterParameter : AUParameterAddress {
    ModalResonanceFilterParameterFrequency,
    ModalResonanceFilterParameterQualityFactor,
};

class ModalResonanceFilterDSP : public SoundpipeDSPBase {
private:
    sp_mode *mode0;
    sp_mode *mode1;
    ParameterRamper frequencyRamp;
    ParameterRamper qualityFactorRamp;

public:
    ModalResonanceFilterDSP() {
        parameters[ModalResonanceFilterParameterFrequency] = &frequencyRamp;
        parameters[ModalResonanceFilterParameterQualityFactor] = &qualityFactorRamp;
    }

    void init(int channelCount, double sampleRate) override {
        SoundpipeDSPBase::init(channelCount, sampleRate);
        sp_mode_create(&mode0);
        sp_mode_init(sp, mode0);
        sp_mode_create(&mode1);
        sp_mode_init(sp, mode1);
    }

    void deinit() override {
        SoundpipeDSPBase::deinit();
        sp_mode_destroy(&mode0);
        sp_mode_destroy(&mode1);
    }

    void reset() override {
        SoundpipeDSPBase::reset();
        if (!isInitialized) return;
        sp_mode_init(sp, mode0);
        sp_mode_init(sp, mode1);
    }

    void process(FrameRange range) override {
        for (int i : range) {

            mode0->freq = mode1->freq = frequencyRamp.getAndStep();
            mode0->q = mode1->q = qualityFactorRamp.getAndStep();

            float leftIn = inputSample(0, i);
            float rightIn = inputSample(1, i);

            float &leftOut = outputSample(0, i);
            float &rightOut = outputSample(1, i);

            sp_mode_compute(sp, mode0, &leftIn, &leftOut);
            sp_mode_compute(sp, mode1, &rightIn, &rightOut);
        }
    }
};

AK_REGISTER_DSP(ModalResonanceFilterDSP, "modf")
AK_REGISTER_PARAMETER(ModalResonanceFilterParameterFrequency)
AK_REGISTER_PARAMETER(ModalResonanceFilterParameterQualityFactor)
