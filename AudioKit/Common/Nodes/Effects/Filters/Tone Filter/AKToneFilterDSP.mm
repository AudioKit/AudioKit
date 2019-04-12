//
//  AKToneFilterDSP.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#include "AKToneFilterDSP.hpp"
#import "AKLinearParameterRamp.hpp"

extern "C" AKDSPRef createToneFilterDSP(int channelCount, double sampleRate) {
    AKToneFilterDSP *dsp = new AKToneFilterDSP();
    dsp->init(channelCount, sampleRate);
    return dsp;
}

struct AKToneFilterDSP::InternalData {
    sp_tone *tone0;
    sp_tone *tone1;
    AKLinearParameterRamp halfPowerPointRamp;
};

AKToneFilterDSP::AKToneFilterDSP() : data(new InternalData) {
    data->halfPowerPointRamp.setTarget(defaultHalfPowerPoint, true);
    data->halfPowerPointRamp.setDurationInSamples(defaultRampDurationSamples);
}

// Uses the ParameterAddress as a key
void AKToneFilterDSP::setParameter(AUParameterAddress address, AUValue value, bool immediate) {
    switch (address) {
        case AKToneFilterParameterHalfPowerPoint:
            data->halfPowerPointRamp.setTarget(clamp(value, halfPowerPointLowerBound, halfPowerPointUpperBound), immediate);
            break;
        case AKToneFilterParameterRampDuration:
            data->halfPowerPointRamp.setRampDuration(value, sampleRate);
            break;
    }
}

// Uses the ParameterAddress as a key
float AKToneFilterDSP::getParameter(uint64_t address) {
    switch (address) {
        case AKToneFilterParameterHalfPowerPoint:
            return data->halfPowerPointRamp.getTarget();
        case AKToneFilterParameterRampDuration:
            return data->halfPowerPointRamp.getRampDuration(sampleRate);
    }
    return 0;
}

void AKToneFilterDSP::init(int channelCount, double sampleRate) {
    AKSoundpipeDSPBase::init(channelCount, sampleRate);
    sp_tone_create(&data->tone0);
    sp_tone_init(sp, data->tone0);
    sp_tone_create(&data->tone1);
    sp_tone_init(sp, data->tone1);
    data->tone0->hp = defaultHalfPowerPoint;
    data->tone1->hp = defaultHalfPowerPoint;
}

void AKToneFilterDSP::deinit() {
    sp_tone_destroy(&data->tone0);
    sp_tone_destroy(&data->tone1);
}

void AKToneFilterDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);

        // do ramping every 8 samples
        if ((frameOffset & 0x7) == 0) {
            data->halfPowerPointRamp.advanceTo(now + frameOffset);
        }

        data->tone0->hp = data->halfPowerPointRamp.getValue();
        data->tone1->hp = data->halfPowerPointRamp.getValue();

        float *tmpin[2];
        float *tmpout[2];
        for (int channel = 0; channel < channelCount; ++channel) {
            float *in  = (float *)inBufferListPtr->mBuffers[channel].mData  + frameOffset;
            float *out = (float *)outBufferListPtr->mBuffers[channel].mData + frameOffset;
            if (channel < 2) {
                tmpin[channel] = in;
                tmpout[channel] = out;
            }
            if (!isStarted) {
                *out = *in;
                continue;
            }

            if (channel == 0) {
                sp_tone_compute(sp, data->tone0, in, out);
            } else {
                sp_tone_compute(sp, data->tone1, in, out);
            }
        }
    }
}
