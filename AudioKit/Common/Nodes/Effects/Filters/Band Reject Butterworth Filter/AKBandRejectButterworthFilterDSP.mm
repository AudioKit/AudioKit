//
//  AKBandRejectButterworthFilterDSP.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#include "AKBandRejectButterworthFilterDSP.hpp"
#import "AKLinearParameterRamp.hpp"

extern "C" AKDSPRef createBandRejectButterworthFilterDSP(int channelCount, double sampleRate) {
    AKBandRejectButterworthFilterDSP *dsp = new AKBandRejectButterworthFilterDSP();
    dsp->init(channelCount, sampleRate);
    return dsp;
}

struct AKBandRejectButterworthFilterDSP::InternalData {
    sp_butbr *butbr0;
    sp_butbr *butbr1;
    AKLinearParameterRamp centerFrequencyRamp;
    AKLinearParameterRamp bandwidthRamp;
};

AKBandRejectButterworthFilterDSP::AKBandRejectButterworthFilterDSP() : data(new InternalData) {
    data->centerFrequencyRamp.setTarget(defaultCenterFrequency, true);
    data->centerFrequencyRamp.setDurationInSamples(defaultRampDurationSamples);
    data->bandwidthRamp.setTarget(defaultBandwidth, true);
    data->bandwidthRamp.setDurationInSamples(defaultRampDurationSamples);
}

// Uses the ParameterAddress as a key
void AKBandRejectButterworthFilterDSP::setParameter(AUParameterAddress address, AUValue value, bool immediate) {
    switch (address) {
        case AKBandRejectButterworthFilterParameterCenterFrequency:
            data->centerFrequencyRamp.setTarget(clamp(value, centerFrequencyLowerBound, centerFrequencyUpperBound), immediate);
            break;
        case AKBandRejectButterworthFilterParameterBandwidth:
            data->bandwidthRamp.setTarget(clamp(value, bandwidthLowerBound, bandwidthUpperBound), immediate);
            break;
        case AKBandRejectButterworthFilterParameterRampDuration:
            data->centerFrequencyRamp.setRampDuration(value, sampleRate);
            data->bandwidthRamp.setRampDuration(value, sampleRate);
            break;
    }
}

// Uses the ParameterAddress as a key
float AKBandRejectButterworthFilterDSP::getParameter(uint64_t address) {
    switch (address) {
        case AKBandRejectButterworthFilterParameterCenterFrequency:
            return data->centerFrequencyRamp.getTarget();
        case AKBandRejectButterworthFilterParameterBandwidth:
            return data->bandwidthRamp.getTarget();
        case AKBandRejectButterworthFilterParameterRampDuration:
            return data->centerFrequencyRamp.getRampDuration(sampleRate);
    }
    return 0;
}

void AKBandRejectButterworthFilterDSP::init(int channelCount, double sampleRate) {
    AKSoundpipeDSPBase::init(channelCount, sampleRate);
    sp_butbr_create(&data->butbr0);
    sp_butbr_init(sp, data->butbr0);
    sp_butbr_create(&data->butbr1);
    sp_butbr_init(sp, data->butbr1);
    data->butbr0->freq = defaultCenterFrequency;
    data->butbr1->freq = defaultCenterFrequency;
    data->butbr0->bw = defaultBandwidth;
    data->butbr1->bw = defaultBandwidth;
}

void AKBandRejectButterworthFilterDSP::deinit() {
    sp_butbr_destroy(&data->butbr0);
    sp_butbr_destroy(&data->butbr1);
}

void AKBandRejectButterworthFilterDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);

        // do ramping every 8 samples
        if ((frameOffset & 0x7) == 0) {
            data->centerFrequencyRamp.advanceTo(now + frameOffset);
            data->bandwidthRamp.advanceTo(now + frameOffset);
        }

        data->butbr0->freq = data->centerFrequencyRamp.getValue();
        data->butbr1->freq = data->centerFrequencyRamp.getValue();
        data->butbr0->bw = data->bandwidthRamp.getValue();
        data->butbr1->bw = data->bandwidthRamp.getValue();

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
                sp_butbr_compute(sp, data->butbr0, in, out);
            } else {
                sp_butbr_compute(sp, data->butbr1, in, out);
            }
        }
    }
}
