// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "AKPinkNoiseDSP.hpp"
#include "AKLinearParameterRamp.hpp"

extern "C" AKDSPRef createPinkNoiseDSP() {
    return new AKPinkNoiseDSP();
}

struct AKPinkNoiseDSP::InternalData {
    sp_pinknoise *pinknoise;
    AKLinearParameterRamp amplitudeRamp;
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

        // do ramping every 8 samples
        if ((frameOffset & 0x7) == 0) {
            data->amplitudeRamp.advanceTo(now + frameOffset);
        }

        data->pinknoise->amp = data->amplitudeRamp.getValue();

        float temp = 0;
        for (int channel = 0; channel < channelCount; ++channel) {
            float *out = (float *)outBufferListPtr->mBuffers[channel].mData + frameOffset;

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
