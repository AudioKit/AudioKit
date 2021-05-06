// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "SoundpipeDSPBase.h"
#include "ParameterRamper.h"
#include "soundpipe.h"

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
        isStarted = false;
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

AK_REGISTER_DSP(PinkNoiseDSP, "pink")
AK_REGISTER_PARAMETER(PinkNoiseParameterAmplitude)
