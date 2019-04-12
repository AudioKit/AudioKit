//
//  AKPinkNoiseDSP.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#include "AKPinkNoiseDSP.hpp"
#import "AKLinearParameterRamp.hpp"

extern "C" AKDSPRef createPinkNoiseDSP(int channelCount, double sampleRate) {
    AKPinkNoiseDSP *dsp = new AKPinkNoiseDSP();
    dsp->init(channelCount, sampleRate);
    return dsp;
}

struct AKPinkNoiseDSP::InternalData {
    sp_pinknoise *pinknoise;
    AKLinearParameterRamp amplitudeRamp;
};

AKPinkNoiseDSP::AKPinkNoiseDSP() : data(new InternalData) {
    data->amplitudeRamp.setTarget(defaultAmplitude, true);
    data->amplitudeRamp.setDurationInSamples(defaultRampDurationSamples);
}

// Uses the ParameterAddress as a key
void AKPinkNoiseDSP::setParameter(AUParameterAddress address, AUValue value, bool immediate) {
    switch (address) {
        case AKPinkNoiseParameterAmplitude:
            data->amplitudeRamp.setTarget(clamp(value, amplitudeLowerBound, amplitudeUpperBound), immediate);
            break;
        case AKPinkNoiseParameterRampDuration:
            data->amplitudeRamp.setRampDuration(value, sampleRate);
            break;
    }
}

// Uses the ParameterAddress as a key
float AKPinkNoiseDSP::getParameter(uint64_t address) {
    switch (address) {
        case AKPinkNoiseParameterAmplitude:
            return data->amplitudeRamp.getTarget();
        case AKPinkNoiseParameterRampDuration:
            return data->amplitudeRamp.getRampDuration(sampleRate);
    }
    return 0;
}

void AKPinkNoiseDSP::init(int channelCount, double sampleRate) {
    AKSoundpipeDSPBase::init(channelCount, sampleRate);
    sp_pinknoise_create(&data->pinknoise);
    sp_pinknoise_init(sp, data->pinknoise);
    data->pinknoise->amp = defaultAmplitude;
}

void AKPinkNoiseDSP::deinit() {
    sp_pinknoise_destroy(&data->pinknoise);
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
