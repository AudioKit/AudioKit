//
//  AKBandPassButterworthFilterDSP.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#include "AKBandPassButterworthFilterDSP.hpp"
#import "AKLinearParameterRamp.hpp"

extern "C" AKDSPRef createBandPassButterworthFilterDSP(int channelCount, double sampleRate) {
    AKBandPassButterworthFilterDSP *dsp = new AKBandPassButterworthFilterDSP();
    dsp->init(channelCount, sampleRate);
    return dsp;
}

struct AKBandPassButterworthFilterDSP::InternalData {
    sp_butbp *butbp0;
    sp_butbp *butbp1;
    AKLinearParameterRamp centerFrequencyRamp;
    AKLinearParameterRamp bandwidthRamp;
};

AKBandPassButterworthFilterDSP::AKBandPassButterworthFilterDSP() : data(new InternalData) {
    data->centerFrequencyRamp.setTarget(defaultCenterFrequency, true);
    data->centerFrequencyRamp.setDurationInSamples(defaultRampDurationSamples);
    data->bandwidthRamp.setTarget(defaultBandwidth, true);
    data->bandwidthRamp.setDurationInSamples(defaultRampDurationSamples);
}

// Uses the ParameterAddress as a key
void AKBandPassButterworthFilterDSP::setParameter(AUParameterAddress address, AUValue value, bool immediate) {
    switch (address) {
        case AKBandPassButterworthFilterParameterCenterFrequency:
            data->centerFrequencyRamp.setTarget(clamp(value, centerFrequencyLowerBound, centerFrequencyUpperBound), immediate);
            break;
        case AKBandPassButterworthFilterParameterBandwidth:
            data->bandwidthRamp.setTarget(clamp(value, bandwidthLowerBound, bandwidthUpperBound), immediate);
            break;
        case AKBandPassButterworthFilterParameterRampDuration:
            data->centerFrequencyRamp.setRampDuration(value, sampleRate);
            data->bandwidthRamp.setRampDuration(value, sampleRate);
            break;
    }
}

// Uses the ParameterAddress as a key
float AKBandPassButterworthFilterDSP::getParameter(uint64_t address) {
    switch (address) {
        case AKBandPassButterworthFilterParameterCenterFrequency:
            return data->centerFrequencyRamp.getTarget();
        case AKBandPassButterworthFilterParameterBandwidth:
            return data->bandwidthRamp.getTarget();
        case AKBandPassButterworthFilterParameterRampDuration:
            return data->centerFrequencyRamp.getRampDuration(sampleRate);
    }
    return 0;
}

void AKBandPassButterworthFilterDSP::init(int channelCount, double sampleRate) {
    AKSoundpipeDSPBase::init(channelCount, sampleRate);
    sp_butbp_create(&data->butbp0);
    sp_butbp_init(sp, data->butbp0);
    sp_butbp_create(&data->butbp1);
    sp_butbp_init(sp, data->butbp1);
    data->butbp0->freq = defaultCenterFrequency;
    data->butbp1->freq = defaultCenterFrequency;
    data->butbp0->bw = defaultBandwidth;
    data->butbp1->bw = defaultBandwidth;
}

void AKBandPassButterworthFilterDSP::deinit() {
    sp_butbp_destroy(&data->butbp0);
    sp_butbp_destroy(&data->butbp1);
}

void AKBandPassButterworthFilterDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);

        // do ramping every 8 samples
        if ((frameOffset & 0x7) == 0) {
            data->centerFrequencyRamp.advanceTo(now + frameOffset);
            data->bandwidthRamp.advanceTo(now + frameOffset);
        }

        data->butbp0->freq = data->centerFrequencyRamp.getValue();
        data->butbp1->freq = data->centerFrequencyRamp.getValue();
        data->butbp0->bw = data->bandwidthRamp.getValue();
        data->butbp1->bw = data->bandwidthRamp.getValue();

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
                sp_butbp_compute(sp, data->butbp0, in, out);
            } else {
                sp_butbp_compute(sp, data->butbp1, in, out);
            }
        }
    }
}
