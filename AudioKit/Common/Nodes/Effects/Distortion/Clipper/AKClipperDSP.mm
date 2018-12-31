//
//  AKClipperDSP.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#include "AKClipperDSP.hpp"
#import "AKLinearParameterRamp.hpp"

extern "C" AKDSPRef createClipperDSP(int channelCount, double sampleRate) {
    AKClipperDSP *dsp = new AKClipperDSP();
    dsp->init(channelCount, sampleRate);
    return dsp;
}

struct AKClipperDSP::InternalData {
    sp_clip *clip0;
    sp_clip *clip1;
    AKLinearParameterRamp limitRamp;
};

AKClipperDSP::AKClipperDSP() : data(new InternalData) {
    data->limitRamp.setTarget(defaultLimit, true);
    data->limitRamp.setDurationInSamples(defaultRampDurationSamples);
}

// Uses the ParameterAddress as a key
void AKClipperDSP::setParameter(AUParameterAddress address, AUValue value, bool immediate) {
    switch (address) {
        case AKClipperParameterLimit:
            data->limitRamp.setTarget(clamp(value, limitLowerBound, limitUpperBound), immediate);
            break;
        case AKClipperParameterRampDuration:
            data->limitRamp.setRampDuration(value, sampleRate);
            break;
    }
}

// Uses the ParameterAddress as a key
float AKClipperDSP::getParameter(uint64_t address) {
    switch (address) {
        case AKClipperParameterLimit:
            return data->limitRamp.getTarget();
        case AKClipperParameterRampDuration:
            return data->limitRamp.getRampDuration(sampleRate);
    }
    return 0;
}

void AKClipperDSP::init(int channelCount, double sampleRate) {
    AKSoundpipeDSPBase::init(channelCount, sampleRate);
    sp_clip_create(&data->clip0);
    sp_clip_init(sp, data->clip0);
    sp_clip_create(&data->clip1);
    sp_clip_init(sp, data->clip1);
    data->clip0->lim = defaultLimit;
    data->clip1->lim = defaultLimit;
}

void AKClipperDSP::deinit() {
    sp_clip_destroy(&data->clip0);
    sp_clip_destroy(&data->clip1);
}

void AKClipperDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);

        // do ramping every 8 samples
        if ((frameOffset & 0x7) == 0) {
            data->limitRamp.advanceTo(now + frameOffset);
        }

        data->clip0->lim = data->limitRamp.getValue();
        data->clip1->lim = data->limitRamp.getValue();

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
                sp_clip_compute(sp, data->clip0, in, out);
            } else {
                sp_clip_compute(sp, data->clip1, in, out);
            }
        }
    }
}
