// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "AKPinkNoiseDSP.hpp"
#include "ParameterRamper.hpp"

#import "AKSoundpipeDSPBase.hpp"

class AKPinkNoiseDSP : public AKSoundpipeDSPBase {
private:
    sp_pinknoise *pinknoise;
    ParameterRamper amplitudeRamp;

public:
    AKPinkNoiseDSP() {
        parameters[AKPinkNoiseParameterAmplitude] = &amplitudeRamp;
    }

    void init(int channelCount, double sampleRate) {
        AKSoundpipeDSPBase::init(channelCount, sampleRate);
        sp_pinknoise_create(&pinknoise);
        sp_pinknoise_init(sp, pinknoise);
    }

    void deinit() {
        AKSoundpipeDSPBase::deinit();
        sp_pinknoise_destroy(&pinknoise);
    }

    void reset() {
        AKSoundpipeDSPBase::reset();
        if (!isInitialized) return;
        sp_pinknoise_init(sp, pinknoise);
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {
        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            int frameOffset = int(frameIndex + bufferOffset);

            pinknoise->amp = amplitudeRamp.getAndStep();
            float temp = 0;
            for (int channel = 0; channel < channelCount; ++channel) {
                float *out = (float *)outputBufferLists[0]->mBuffers[channel].mData + frameOffset;

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

extern "C" AKDSPRef createPinkNoiseDSP() {
    return new AKPinkNoiseDSP();
}
