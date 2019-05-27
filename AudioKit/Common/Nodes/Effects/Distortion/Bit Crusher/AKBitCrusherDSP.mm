//
//  AKBitCrusherDSP.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#include "AKBitCrusherDSP.hpp"
#import "AKLinearParameterRamp.hpp"

extern "C" AKDSPRef createBitCrusherDSP(int channelCount, double sampleRate) {
    AKBitCrusherDSP *dsp = new AKBitCrusherDSP();
    dsp->init(channelCount, sampleRate);
    return dsp;
}

struct AKBitCrusherDSP::InternalData {
    sp_bitcrush *bitcrush0;
    sp_bitcrush *bitcrush1;
    AKLinearParameterRamp bitDepthRamp;
    AKLinearParameterRamp sampleRateRamp;
};

AKBitCrusherDSP::AKBitCrusherDSP() : data(new InternalData) {
    data->bitDepthRamp.setTarget(defaultBitDepth, true);
    data->bitDepthRamp.setDurationInSamples(defaultRampDurationSamples);
    data->sampleRateRamp.setTarget(defaultSampleRate, true);
    data->sampleRateRamp.setDurationInSamples(defaultRampDurationSamples);
}

// Uses the ParameterAddress as a key
void AKBitCrusherDSP::setParameter(AUParameterAddress address, AUValue value, bool immediate) {
    switch (address) {
        case AKBitCrusherParameterBitDepth:
            data->bitDepthRamp.setTarget(clamp(value, bitDepthLowerBound, bitDepthUpperBound), immediate);
            break;
        case AKBitCrusherParameterSampleRate:
            data->sampleRateRamp.setTarget(clamp(value, sampleRateLowerBound, sampleRateUpperBound), immediate);
            break;
        case AKBitCrusherParameterRampDuration:
            data->bitDepthRamp.setRampDuration(value, sampleRate);
            data->sampleRateRamp.setRampDuration(value, sampleRate);
            break;
    }
}

// Uses the ParameterAddress as a key
float AKBitCrusherDSP::getParameter(uint64_t address) {
    switch (address) {
        case AKBitCrusherParameterBitDepth:
            return data->bitDepthRamp.getTarget();
        case AKBitCrusherParameterSampleRate:
            return data->sampleRateRamp.getTarget();
        case AKBitCrusherParameterRampDuration:
            return data->bitDepthRamp.getRampDuration(sampleRate);
    }
    return 0;
}

void AKBitCrusherDSP::init(int channelCount, double sampleRate) {
    AKSoundpipeDSPBase::init(channelCount, sampleRate);
    sp_bitcrush_create(&data->bitcrush0);
    sp_bitcrush_init(sp, data->bitcrush0);
    sp_bitcrush_create(&data->bitcrush1);
    sp_bitcrush_init(sp, data->bitcrush1);
    data->bitcrush0->bitdepth = defaultBitDepth;
    data->bitcrush1->bitdepth = defaultBitDepth;
    data->bitcrush0->srate = defaultSampleRate;
    data->bitcrush1->srate = defaultSampleRate;
}

void AKBitCrusherDSP::deinit() {
    sp_bitcrush_destroy(&data->bitcrush0);
    sp_bitcrush_destroy(&data->bitcrush1);
}

void AKBitCrusherDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);

        // do ramping every 8 samples
        if ((frameOffset & 0x7) == 0) {
            data->bitDepthRamp.advanceTo(now + frameOffset);
            data->sampleRateRamp.advanceTo(now + frameOffset);
        }

        data->bitcrush0->bitdepth = data->bitDepthRamp.getValue();
        data->bitcrush1->bitdepth = data->bitDepthRamp.getValue();
        data->bitcrush0->srate = data->sampleRateRamp.getValue();
        data->bitcrush1->srate = data->sampleRateRamp.getValue();

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
                sp_bitcrush_compute(sp, data->bitcrush0, in, out);
            } else {
                sp_bitcrush_compute(sp, data->bitcrush1, in, out);
            }
        }
    }
}
