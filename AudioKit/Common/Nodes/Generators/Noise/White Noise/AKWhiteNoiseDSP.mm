//
//  AKWhiteNoiseDSP.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2020 AudioKit. All rights reserved.
//

#include "AKWhiteNoiseDSP.hpp"
#include "AKLinearParameterRamp.hpp"

extern "C" AKDSPRef createWhiteNoiseDSP() {
    return new AKWhiteNoiseDSP();
}

struct AKWhiteNoiseDSP::InternalData {
    sp_noise *noise;
    AKLinearParameterRamp amplitudeRamp;
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

        // do ramping every 8 samples
        if ((frameOffset & 0x7) == 0) {
            data->amplitudeRamp.advanceTo(now + frameOffset);
        }

        data->noise->amp = data->amplitudeRamp.getValue();

        float temp = 0;
        for (int channel = 0; channel < channelCount; ++channel) {
            float *out = (float *)outBufferListPtr->mBuffers[channel].mData + frameOffset;

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
