// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "SoundpipeDSPBase.h"
#include "ParameterRamper.h"
#include "Soundpipe.h"

enum BrownianNoiseParameter : AUParameterAddress {
    BrownianNoiseParameterAmplitude,
};

class BrownianNoiseDSP : public SoundpipeDSPBase {
private:
    sp_brown *brown;
    ParameterRamper amplitudeRamp;

public:
    BrownianNoiseDSP() : SoundpipeDSPBase(/*inputBusCount*/0) {
        parameters[BrownianNoiseParameterAmplitude] = &amplitudeRamp;
    }

    void init(int channelCount, double sampleRate) override {
        SoundpipeDSPBase::init(channelCount, sampleRate);
        sp_brown_create(&brown);
        sp_brown_init(sp, brown);
    }

    void deinit() override {
        SoundpipeDSPBase::deinit();
        sp_brown_destroy(&brown);
    }

    void reset() override {
        SoundpipeDSPBase::reset();
        if (!isInitialized) return;
        sp_brown_init(sp, brown);
    }

    void process(FrameRange range) override {

        for (int i : range) {

            float amplitude = amplitudeRamp.getAndStep();

            sp_brown_compute(sp, brown, nil, &outputSample(0, i));
            outputSample(0, i) *= amplitude;
        }
        
        cloneFirstChannel(range);
    }
};

AK_REGISTER_DSP(BrownianNoiseDSP, "bron")
AK_REGISTER_PARAMETER(BrownianNoiseParameterAmplitude)
