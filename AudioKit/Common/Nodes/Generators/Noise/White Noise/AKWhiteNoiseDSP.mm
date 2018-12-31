//
//  AKWhiteNoiseDSP.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#include "AKWhiteNoiseDSP.hpp"
#import "AKLinearParameterRamp.hpp"

extern "C" AKDSPRef createWhiteNoiseDSP(int channelCount, double sampleRate) {
    AKWhiteNoiseDSP *dsp = new AKWhiteNoiseDSP();
    dsp->init(channelCount, sampleRate);
    return dsp;
}

struct AKWhiteNoiseDSP::InternalData {
    sp_noise *noise;
    AKLinearParameterRamp amplitudeRamp;
};

AKWhiteNoiseDSP::AKWhiteNoiseDSP() : data(new InternalData) {
    data->amplitudeRamp.setTarget(defaultAmplitude, true);
    data->amplitudeRamp.setDurationInSamples(defaultRampDurationSamples);
}

// Uses the ParameterAddress as a key
void AKWhiteNoiseDSP::setParameter(AUParameterAddress address, AUValue value, bool immediate) {
    switch (address) {
        case AKWhiteNoiseParameterAmplitude:
            data->amplitudeRamp.setTarget(clamp(value, amplitudeLowerBound, amplitudeUpperBound), immediate);
            break;
        case AKWhiteNoiseParameterRampDuration:
            data->amplitudeRamp.setRampDuration(value, sampleRate);
            break;
    }
}

// Uses the ParameterAddress as a key
float AKWhiteNoiseDSP::getParameter(uint64_t address) {
    switch (address) {
        case AKWhiteNoiseParameterAmplitude:
            return data->amplitudeRamp.getTarget();
        case AKWhiteNoiseParameterRampDuration:
            return data->amplitudeRamp.getRampDuration(sampleRate);
    }
    return 0;
}

void AKWhiteNoiseDSP::init(int channelCount, double sampleRate) {
    AKSoundpipeDSPBase::init(channelCount, sampleRate);
    sp_noise_create(&data->noise);
    sp_noise_init(sp, data->noise);
    data->noise->amp = defaultAmplitude;
}

void AKWhiteNoiseDSP::deinit() {
    sp_noise_destroy(&data->noise);
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
