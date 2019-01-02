//
//  AKBrownianNoiseDSP.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#include "AKBrownianNoiseDSP.hpp"
#import "AKLinearParameterRamp.hpp"

extern "C" AKDSPRef createBrownianNoiseDSP(int channelCount, double sampleRate) {
    AKBrownianNoiseDSP *dsp = new AKBrownianNoiseDSP();
    dsp->init(channelCount, sampleRate);
    return dsp;
}

struct AKBrownianNoiseDSP::InternalData {
    sp_brown *brown;
    AKLinearParameterRamp amplitudeRamp;
};

AKBrownianNoiseDSP::AKBrownianNoiseDSP() : data(new InternalData) {
    data->amplitudeRamp.setTarget(defaultAmplitude, true);
    data->amplitudeRamp.setDurationInSamples(defaultRampDurationSamples);
}

// Uses the ParameterAddress as a key
void AKBrownianNoiseDSP::setParameter(AUParameterAddress address, AUValue value, bool immediate) {
    switch (address) {
        case AKBrownianNoiseParameterAmplitude:
            data->amplitudeRamp.setTarget(clamp(value, amplitudeLowerBound, amplitudeUpperBound), immediate);
            break;
        case AKBrownianNoiseParameterRampDuration:
            data->amplitudeRamp.setRampDuration(value, sampleRate);
            break;
    }
}

// Uses the ParameterAddress as a key
float AKBrownianNoiseDSP::getParameter(uint64_t address) {
    switch (address) {
        case AKBrownianNoiseParameterAmplitude:
            return data->amplitudeRamp.getTarget();
        case AKBrownianNoiseParameterRampDuration:
            return data->amplitudeRamp.getRampDuration(sampleRate);
    }
    return 0;
}

void AKBrownianNoiseDSP::init(int channelCount, double sampleRate) {
    AKSoundpipeDSPBase::init(channelCount, sampleRate);
    sp_brown_create(&data->brown);
    sp_brown_init(sp, data->brown);
}

void AKBrownianNoiseDSP::deinit() {
    sp_brown_destroy(&data->brown);
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
            float *out = (float *)outBufferListPtr->mBuffers[channel].mData + frameOffset;

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
