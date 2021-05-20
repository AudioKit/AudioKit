// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "SoundpipeDSPBase.h"
#include "ParameterRamper.h"
#include "Soundpipe.h"

enum PinkNoiseParameter : AUParameterAddress {
    PinkNoiseParameterAmplitude,
};

class PinkNoiseDSP : public SoundpipeDSPBase {
private:
    sp_pinknoise *pinknoise;
    ParameterRamper amplitudeRamp;

public:
    PinkNoiseDSP() : SoundpipeDSPBase(/*inputBusCount*/0) {
        parameters[PinkNoiseParameterAmplitude] = &amplitudeRamp;
    }

    void init(int channelCount, double sampleRate) override {
        SoundpipeDSPBase::init(channelCount, sampleRate);
        sp_pinknoise_create(&pinknoise);
        sp_pinknoise_init(sp, pinknoise);
    }

    void deinit() override {
        SoundpipeDSPBase::deinit();
        sp_pinknoise_destroy(&pinknoise);
    }

    void reset() override {
        SoundpipeDSPBase::reset();
        if (!isInitialized) return;
        sp_pinknoise_init(sp, pinknoise);
    }

    void process(FrameRange range) override {

        for (int i : range) {

            pinknoise->amp = amplitudeRamp.getAndStep();
            
            sp_pinknoise_compute(sp, pinknoise, nil, &outputSample(0, i));
        }
        
        cloneFirstChannel(range);
    }
};

AK_REGISTER_DSP(PinkNoiseDSP, "pink")
AK_REGISTER_PARAMETER(PinkNoiseParameterAmplitude)
