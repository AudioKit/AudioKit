// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "AKBrownianNoiseDSP.hpp"
#include "ParameterRamper.hpp"

#import "AKSoundpipeDSPBase.hpp"

class AKBrownianNoiseDSP : public AKSoundpipeDSPBase {
private:
    sp_brown *brown;
    ParameterRamper amplitudeRamp;

public:
    AKBrownianNoiseDSP() {
        parameters[AKBrownianNoiseParameterAmplitude] = &amplitudeRamp;
    }

    void init(int channelCount, double sampleRate) override {
        AKSoundpipeDSPBase::init(channelCount, sampleRate);
        sp_brown_create(&brown);
        sp_brown_init(sp, brown);
    }

    void deinit() override {
        AKSoundpipeDSPBase::deinit();
        sp_brown_destroy(&brown);
    }

    void reset() override {
        AKSoundpipeDSPBase::reset();
        if (!isInitialized) return;
        sp_brown_init(sp, brown);
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {
        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            int frameOffset = int(frameIndex + bufferOffset);

            float amplitude = amplitudeRamp.getAndStep();

            float temp = 0;
            for (int channel = 0; channel < channelCount; ++channel) {
                float *out = (float *)outputBufferLists[0]->mBuffers[channel].mData + frameOffset;

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

extern "C" AKDSPRef createBrownianNoiseDSP() {
    return new AKBrownianNoiseDSP();
}
