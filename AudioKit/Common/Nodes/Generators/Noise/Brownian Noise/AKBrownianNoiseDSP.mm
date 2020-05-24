// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "AKBrownianNoiseDSP.hpp"
#include "AKLinearParameterRamp.hpp"

extern "C" AKDSPRef createBrownianNoiseDSP() {
    return new AKBrownianNoiseDSP();
}

struct AKBrownianNoiseDSP::InternalData {
    sp_brown *brown;
    AKLinearParameterRamp amplitudeRamp;
};

AKBrownianNoiseDSP::AKBrownianNoiseDSP() : data(new InternalData) {
    parameters[AKBrownianNoiseParameterAmplitude] = &data->amplitudeRamp;
}

void AKBrownianNoiseDSP::init(int channelCount, double sampleRate) {
    AKSoundpipeDSPBase::init(channelCount, sampleRate);
    sp_brown_create(&data->brown);
    sp_brown_init(sp, data->brown);
}

void AKBrownianNoiseDSP::deinit() {
    AKSoundpipeDSPBase::deinit();
    sp_brown_destroy(&data->brown);
}

void AKBrownianNoiseDSP::reset() {
    AKSoundpipeDSPBase::reset();
    if (!isInitialized) return;
    sp_brown_init(sp, data->brown);
}

void AKBrownianNoiseDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {
    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);

        // do ramping every 8 samples
        if ((frameOffset & 0x7) == 0) {
            data->amplitudeRamp.advanceTo(now + frameOffset);
        }

        float temp = 0;
        for (int channel = 0; channel < channelCount; ++channel) {
            float *out = (float *)outputBufferLists[0]->mBuffers[channel].mData + frameOffset;

            if (isStarted) {
                if (channel == 0) {
                    sp_brown_compute(sp, data->brown, nil, &temp);
                }
                *out = temp * data->amplitudeRamp.getValue();
            } else {
                *out = 0.0;
            }
        }
    }
}
