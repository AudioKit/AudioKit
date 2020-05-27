// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "AKPinkNoiseDSP.hpp"
#include "ParameterRamper.hpp"

extern "C" AKDSPRef createPinkNoiseDSP() {
    return new AKPinkNoiseDSP();
}

struct AKPinkNoiseDSP::InternalData {
    sp_pinknoise *pinknoise;
    ParameterRamper amplitudeRamp;
};

AKPinkNoiseDSP::AKPinkNoiseDSP() : data(new InternalData) {
    parameters[AKPinkNoiseParameterAmplitude] = &data->amplitudeRamp;
}

void AKPinkNoiseDSP::init(int channelCount, double sampleRate) {
    AKSoundpipeDSPBase::init(channelCount, sampleRate);
    sp_pinknoise_create(&data->pinknoise);
    sp_pinknoise_init(sp, data->pinknoise);
}

void AKPinkNoiseDSP::deinit() {
    AKSoundpipeDSPBase::deinit();
    sp_pinknoise_destroy(&data->pinknoise);
}

void AKPinkNoiseDSP::reset() {
    AKSoundpipeDSPBase::reset();
    if (!isInitialized) return;
    sp_pinknoise_init(sp, data->pinknoise);
}

void AKPinkNoiseDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {
    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);

        data->pinknoise->amp = data->amplitudeRamp.getAndStep();

        float temp = 0;
        for (int channel = 0; channel < channelCount; ++channel) {
            float *out = (float *)outputBufferLists[0]->mBuffers[channel].mData + frameOffset;

            if (isStarted) {
                if (channel == 0) {
                    sp_pinknoise_compute(sp, data->pinknoise, nil, &temp);
                }
                *out = temp;
            } else {
                *out = 0.0;
            }
        }
    }
}
