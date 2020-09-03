// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "AKSoundpipeDSPBase.hpp"
#include "ParameterRamper.hpp"
#include "soundpipe.h"

enum AKPluckedStringParameter : AUParameterAddress {
    AKPluckedStringParameterFrequency,
    AKPluckedStringParameterAmplitude,
};

class AKPluckedStringDSP : public AKSoundpipeDSPBase {
private:
    sp_pluck *pluck;
    float internalTrigger = 0;
    ParameterRamper frequencyRamp;
    ParameterRamper amplitudeRamp;

public:
    AKPluckedStringDSP() : AKSoundpipeDSPBase(/*inputBusCount*/0) {
        parameters[AKPluckedStringParameterFrequency] = &frequencyRamp;
        parameters[AKPluckedStringParameterAmplitude] = &amplitudeRamp;
    }

    void init(int channelCount, double sampleRate) override {
        AKSoundpipeDSPBase::init(channelCount, sampleRate);
        sp_pluck_create(&pluck);
        sp_pluck_init(sp, pluck, 110);
    }

    void deinit() override {
        AKSoundpipeDSPBase::deinit();
        sp_pluck_destroy(&pluck);
    }

    void reset() override {
        AKSoundpipeDSPBase::reset();
        if (!isInitialized) return;
        sp_pluck_init(sp, pluck, 110);
    }

    void trigger() override {
        internalTrigger = 1;
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {
        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            int frameOffset = int(frameIndex + bufferOffset);

            pluck->freq = frequencyRamp.getAndStep();
            pluck->amp = amplitudeRamp.getAndStep();

            for (int channel = 0; channel < channelCount; ++channel) {
                float *out = (float *)outputBufferList->mBuffers[channel].mData + frameOffset;

                if (isStarted) {
                    if (channel == 0) {
                        sp_pluck_compute(sp, pluck, &internalTrigger, out);
                    }
                } else {
                    *out = 0.0;
                }
            }
        }
        if (internalTrigger == 1) {
            internalTrigger = 0;
        }
    }
};

AK_REGISTER_DSP(AKPluckedStringDSP)
AK_REGISTER_PARAMETER(AKPluckedStringParameterFrequency)
AK_REGISTER_PARAMETER(AKPluckedStringParameterAmplitude)
