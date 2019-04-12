//
//  AKResonantFilterDSP.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#include "AKResonantFilterDSP.hpp"
#import "AKLinearParameterRamp.hpp"

extern "C" AKDSPRef createResonantFilterDSP(int channelCount, double sampleRate) {
    AKResonantFilterDSP *dsp = new AKResonantFilterDSP();
    dsp->init(channelCount, sampleRate);
    return dsp;
}

struct AKResonantFilterDSP::InternalData {
    sp_reson *reson0;
    sp_reson *reson1;
    AKLinearParameterRamp frequencyRamp;
    AKLinearParameterRamp bandwidthRamp;
};

AKResonantFilterDSP::AKResonantFilterDSP() : data(new InternalData) {
    data->frequencyRamp.setTarget(defaultFrequency, true);
    data->frequencyRamp.setDurationInSamples(defaultRampDurationSamples);
    data->bandwidthRamp.setTarget(defaultBandwidth, true);
    data->bandwidthRamp.setDurationInSamples(defaultRampDurationSamples);
}

// Uses the ParameterAddress as a key
void AKResonantFilterDSP::setParameter(AUParameterAddress address, AUValue value, bool immediate) {
    switch (address) {
        case AKResonantFilterParameterFrequency:
            data->frequencyRamp.setTarget(clamp(value, frequencyLowerBound, frequencyUpperBound), immediate);
            break;
        case AKResonantFilterParameterBandwidth:
            data->bandwidthRamp.setTarget(clamp(value, bandwidthLowerBound, bandwidthUpperBound), immediate);
            break;
        case AKResonantFilterParameterRampDuration:
            data->frequencyRamp.setRampDuration(value, sampleRate);
            data->bandwidthRamp.setRampDuration(value, sampleRate);
            break;
    }
}

// Uses the ParameterAddress as a key
float AKResonantFilterDSP::getParameter(uint64_t address) {
    switch (address) {
        case AKResonantFilterParameterFrequency:
            return data->frequencyRamp.getTarget();
        case AKResonantFilterParameterBandwidth:
            return data->bandwidthRamp.getTarget();
        case AKResonantFilterParameterRampDuration:
            return data->frequencyRamp.getRampDuration(sampleRate);
    }
    return 0;
}

void AKResonantFilterDSP::init(int channelCount, double sampleRate) {
    AKSoundpipeDSPBase::init(channelCount, sampleRate);
    sp_reson_create(&data->reson0);
    sp_reson_init(sp, data->reson0);
    sp_reson_create(&data->reson1);
    sp_reson_init(sp, data->reson1);
    data->reson0->freq = defaultFrequency;
    data->reson1->freq = defaultFrequency;
    data->reson0->bw = defaultBandwidth;
    data->reson1->bw = defaultBandwidth;
}

void AKResonantFilterDSP::deinit() {
    sp_reson_destroy(&data->reson0);
    sp_reson_destroy(&data->reson1);
}

void AKResonantFilterDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);

        // do ramping every 8 samples
        if ((frameOffset & 0x7) == 0) {
            data->frequencyRamp.advanceTo(now + frameOffset);
            data->bandwidthRamp.advanceTo(now + frameOffset);
        }

        data->reson0->freq = data->frequencyRamp.getValue();
        data->reson1->freq = data->frequencyRamp.getValue();
        data->reson0->bw = data->bandwidthRamp.getValue();
        data->reson1->bw = data->bandwidthRamp.getValue();

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
                sp_reson_compute(sp, data->reson0, in, out);
            } else {
                sp_reson_compute(sp, data->reson1, in, out);
            }
        }
    }
}
