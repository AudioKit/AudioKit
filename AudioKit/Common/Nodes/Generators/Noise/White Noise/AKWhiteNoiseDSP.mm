// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "AKWhiteNoiseDSP.hpp"
#include "ParameterRamper.hpp"

extern "C" AKDSPRef createWhiteNoiseDSP() {
    return new AKWhiteNoiseDSP();
}

struct AKWhiteNoiseDSP::InternalData {
    sp_noise *noise;
    ParameterRamper amplitudeRamp;
};

AKWhiteNoiseDSP::AKWhiteNoiseDSP() : data(new InternalData) {
    parameters[AKWhiteNoiseParameterAmplitude] = &data->amplitudeRamp;
}

void AKWhiteNoiseDSP::init(int channelCount, double sampleRate) {
    AKSoundpipeDSPBase::init(channelCount, sampleRate);
    sp_noise_create(&data->noise);
    sp_noise_init(sp, data->noise);
}

void AKWhiteNoiseDSP::deinit() {
    AKSoundpipeDSPBase::deinit();
    sp_noise_destroy(&data->noise);
}

void AKWhiteNoiseDSP::reset() {
    AKSoundpipeDSPBase::reset();
    if (!isInitialized) return;
    sp_noise_init(sp, data->noise);
}

void AKWhiteNoiseDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {
    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);

        data->noise->amp = data->amplitudeRamp.getAndStep();

        float temp = 0;
        for (int channel = 0; channel < channelCount; ++channel) {
            float *out = (float *)outputBufferLists[0]->mBuffers[channel].mData + frameOffset;

            if (isStarted) {
                if (channel == 0) {
                    sp_noise_compute(sp, data->noise, nil, &temp);
                }
                *out = temp;
            } else {
                *out = 0.0;
            }
        }
    }
}
