// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "AKSoundpipeDSPBase.hpp"
#include "ParameterRamper.hpp"
#include "soundpipe.h"

enum AKWhiteNoiseParameter : AUParameterAddress {
    AKWhiteNoiseParameterAmplitude,
};

class AKWhiteNoiseDSP : public AKSoundpipeDSPBase {
private:
    sp_noise *noise;
    ParameterRamper amplitudeRamp;

public:
    AKWhiteNoiseDSP() : AKSoundpipeDSPBase(/*inputBusCount*/0) {
        parameters[AKWhiteNoiseParameterAmplitude] = &amplitudeRamp;
        isStarted = false;
    }

    void init(int channelCount, double sampleRate) override {
        AKSoundpipeDSPBase::init(channelCount, sampleRate);
        sp_noise_create(&noise);
        sp_noise_init(sp, noise);
    }

    void deinit() override {
        AKSoundpipeDSPBase::deinit();
        sp_noise_destroy(&noise);
    }

    void reset() override {
        AKSoundpipeDSPBase::reset();
        if (!isInitialized) return;
        sp_noise_init(sp, noise);
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {
        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            int frameOffset = int(frameIndex + bufferOffset);

            noise->amp = amplitudeRamp.getAndStep();
            float temp = 0;
            for (int channel = 0; channel < channelCount; ++channel) {
                float *out = (float *)outputBufferList->mBuffers[channel].mData + frameOffset;

                if (isStarted) {
                    if (channel == 0) {
                        sp_noise_compute(sp, noise, nil, &temp);
                    }
                    *out = temp;
                } else {
                    *out = 0.0;
                }
            }
        }
    }
};

AK_REGISTER_DSP(AKWhiteNoiseDSP)
AK_REGISTER_PARAMETER(AKWhiteNoiseParameterAmplitude)
