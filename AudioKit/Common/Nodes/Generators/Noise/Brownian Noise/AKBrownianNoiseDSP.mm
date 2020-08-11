// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "AudioKit.h"
#include "soundpipe.h"

enum AKBrownianNoiseParameter : AUParameterAddress {
    AKBrownianNoiseParameterAmplitude,
};

class AKBrownianNoiseDSP : public AKSoundpipeDSPBase {
private:
    sp_brown *brown;
    ParameterRamper amplitudeRamp;

public:
    AKBrownianNoiseDSP() {
        parameters[AKBrownianNoiseParameterAmplitude] = &amplitudeRamp;
    }

    void init(int channelCount, double sampleRate) {
        AKSoundpipeDSPBase::init(channelCount, sampleRate);
        sp_brown_create(&brown);
        sp_brown_init(sp, brown);
    }

    void deinit() {
        AKSoundpipeDSPBase::deinit();
        sp_brown_destroy(&brown);
    }

    void reset() {
        AKSoundpipeDSPBase::reset();
        if (!isInitialized) return;
        sp_brown_init(sp, brown);
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {
        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            int frameOffset = int(frameIndex + bufferOffset);

            float amplitude = amplitudeRamp.getAndStep();

            float temp = 0;
            for (int channel = 0; channel < channelCount; ++channel) {
                float *out = (float *)outputBufferList->mBuffers[channel].mData + frameOffset;

                if (isStarted) {
                    if (channel == 0) {
                        sp_brown_compute(sp, brown, nil, &temp);
                    }
                    *out = temp * amplitude;
                } else {
                    *out = 0.0;
                }
            }
        }
    }
};

AK_REGISTER_DSP(AKBrownianNoiseDSP)
AK_REGISTER_PARAMETER(AKBrownianNoiseParameterAmplitude)
