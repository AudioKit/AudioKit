// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "SoundpipeDSPBase.h"
#include "ParameterRamper.h"
#include "Soundpipe.h"

enum WhiteNoiseParameter : AUParameterAddress {
    WhiteNoiseParameterAmplitude,
};

class WhiteNoiseDSP : public SoundpipeDSPBase {
private:
    sp_noise *noise;
    ParameterRamper amplitudeRamp;

public:
    WhiteNoiseDSP() : SoundpipeDSPBase(/*inputBusCount*/0) {
        parameters[WhiteNoiseParameterAmplitude] = &amplitudeRamp;
    }

    void init(int channelCount, double sampleRate) override {
        SoundpipeDSPBase::init(channelCount, sampleRate);
        sp_noise_create(&noise);
        sp_noise_init(sp, noise);
    }

    void deinit() override {
        SoundpipeDSPBase::deinit();
        sp_noise_destroy(&noise);
    }

    void reset() override {
        SoundpipeDSPBase::reset();
        if (!isInitialized) return;
        sp_noise_init(sp, noise);
    }

    void process(FrameRange range) override {

        for (int i : range) {

            noise->amp = amplitudeRamp.getAndStep();
            
            sp_noise_compute(sp, noise, nil, &outputSample(0, i));
        }
        
        cloneFirstChannel(range);
    }
};

AK_REGISTER_DSP(WhiteNoiseDSP, "wnoz")
AK_REGISTER_PARAMETER(WhiteNoiseParameterAmplitude)
