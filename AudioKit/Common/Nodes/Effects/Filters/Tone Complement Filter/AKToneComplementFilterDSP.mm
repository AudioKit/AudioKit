//
//  AKToneComplementFilterDSP.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#include "AKToneComplementFilterDSP.hpp"
#import "AKLinearParameterRamp.hpp"

extern "C" AKDSPRef createToneComplementFilterDSP(int channelCount, double sampleRate) {
    AKToneComplementFilterDSP *dsp = new AKToneComplementFilterDSP();
    dsp->init(channelCount, sampleRate);
    return dsp;
}

struct AKToneComplementFilterDSP::InternalData {
    sp_atone *atone0;
    sp_atone *atone1;
    AKLinearParameterRamp halfPowerPointRamp;
};

AKToneComplementFilterDSP::AKToneComplementFilterDSP() : data(new InternalData) {
    data->halfPowerPointRamp.setTarget(defaultHalfPowerPoint, true);
    data->halfPowerPointRamp.setDurationInSamples(defaultRampDurationSamples);
}

// Uses the ParameterAddress as a key
void AKToneComplementFilterDSP::setParameter(AUParameterAddress address, AUValue value, bool immediate) {
    switch (address) {
        case AKToneComplementFilterParameterHalfPowerPoint:
            data->halfPowerPointRamp.setTarget(clamp(value, halfPowerPointLowerBound, halfPowerPointUpperBound), immediate);
            break;
        case AKToneComplementFilterParameterRampDuration:
            data->halfPowerPointRamp.setRampDuration(value, sampleRate);
            break;
    }
}

// Uses the ParameterAddress as a key
float AKToneComplementFilterDSP::getParameter(uint64_t address) {
    switch (address) {
        case AKToneComplementFilterParameterHalfPowerPoint:
            return data->halfPowerPointRamp.getTarget();
        case AKToneComplementFilterParameterRampDuration:
            return data->halfPowerPointRamp.getRampDuration(sampleRate);
    }
    return 0;
}

void AKToneComplementFilterDSP::init(int channelCount, double sampleRate) {
    AKSoundpipeDSPBase::init(channelCount, sampleRate);
    sp_atone_create(&data->atone0);
    sp_atone_init(sp, data->atone0);
    sp_atone_create(&data->atone1);
    sp_atone_init(sp, data->atone1);
    data->atone0->hp = defaultHalfPowerPoint;
    data->atone1->hp = defaultHalfPowerPoint;
}

void AKToneComplementFilterDSP::deinit() {
    sp_atone_destroy(&data->atone0);
    sp_atone_destroy(&data->atone1);
}

void AKToneComplementFilterDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);

        // do ramping every 8 samples
        if ((frameOffset & 0x7) == 0) {
            data->halfPowerPointRamp.advanceTo(now + frameOffset);
        }

        data->atone0->hp = data->halfPowerPointRamp.getValue();
        data->atone1->hp = data->halfPowerPointRamp.getValue();

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
                sp_atone_compute(sp, data->atone0, in, out);
            } else {
                sp_atone_compute(sp, data->atone1, in, out);
            }
        }
    }
}
