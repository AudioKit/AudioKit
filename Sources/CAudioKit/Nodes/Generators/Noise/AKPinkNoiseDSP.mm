// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "AKSoundpipeDSPBase.hpp"
#include "ParameterRamper.hpp"
#include "soundpipe.h"

enum AKPinkNoiseParameter : AUParameterAddress {
    AKPinkNoiseParameterAmplitude,
};

class AKPinkNoiseDSP : public AKSoundpipeDSPBase {
private:
    sp_pinknoise *pinknoise;
    ParameterRamper amplitudeRamp;

public:
    AKPinkNoiseDSP() : AKSoundpipeDSPBase(/*inputBusCount*/0) {
        parameters[AKPinkNoiseParameterAmplitude] = &amplitudeRamp;
        isStarted = false;
    }

    void init(int channelCount, double sampleRate) override {
        AKSoundpipeDSPBase::init(channelCount, sampleRate);
        sp_pinknoise_create(&pinknoise);
        sp_pinknoise_init(sp, pinknoise);
    }

    void deinit() override {
        AKSoundpipeDSPBase::deinit();
        sp_pinknoise_destroy(&pinknoise);
    }

    void reset() override {
        AKSoundpipeDSPBase::reset();
        if (!isInitialized) return;
        sp_pinknoise_init(sp, pinknoise);
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {
        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            int frameOffset = int(frameIndex + bufferOffset);

            pinknoise->amp = amplitudeRamp.getAndStep();
            float temp = 0;
            for (int channel = 0; channel < channelCount; ++channel) {
                float *out = (float *)outputBufferList->mBuffers[channel].mData + frameOffset;

                if (isStarted) {
                    if (channel == 0) {
                        sp_pinknoise_compute(sp, pinknoise, nil, &temp);
                    }
                    *out = temp;
                } else {
                    *out = 0.0;
                }
            }
        }
    }
};

AK_REGISTER_DSP(AKPinkNoiseDSP)
AK_REGISTER_PARAMETER(AKPinkNoiseParameterAmplitude)
