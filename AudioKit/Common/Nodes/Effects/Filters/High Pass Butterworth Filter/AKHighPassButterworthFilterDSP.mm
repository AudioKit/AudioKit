//
//  AKHighPassButterworthFilterDSP.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#include "AKHighPassButterworthFilterDSP.hpp"
#import "AKLinearParameterRamp.hpp"

extern "C" AKDSPRef createHighPassButterworthFilterDSP(int channelCount, double sampleRate) {
    AKHighPassButterworthFilterDSP *dsp = new AKHighPassButterworthFilterDSP();
    dsp->init(channelCount, sampleRate);
    return dsp;
}

struct AKHighPassButterworthFilterDSP::InternalData {
    sp_buthp *buthp0;
    sp_buthp *buthp1;
    AKLinearParameterRamp cutoffFrequencyRamp;
};

AKHighPassButterworthFilterDSP::AKHighPassButterworthFilterDSP() : data(new InternalData) {
    data->cutoffFrequencyRamp.setTarget(defaultCutoffFrequency, true);
    data->cutoffFrequencyRamp.setDurationInSamples(defaultRampDurationSamples);
}

// Uses the ParameterAddress as a key
void AKHighPassButterworthFilterDSP::setParameter(AUParameterAddress address, AUValue value, bool immediate) {
    switch (address) {
        case AKHighPassButterworthFilterParameterCutoffFrequency:
            data->cutoffFrequencyRamp.setTarget(clamp(value, cutoffFrequencyLowerBound, cutoffFrequencyUpperBound), immediate);
            break;
        case AKHighPassButterworthFilterParameterRampDuration:
            data->cutoffFrequencyRamp.setRampDuration(value, sampleRate);
            break;
    }
}

// Uses the ParameterAddress as a key
float AKHighPassButterworthFilterDSP::getParameter(uint64_t address) {
    switch (address) {
        case AKHighPassButterworthFilterParameterCutoffFrequency:
            return data->cutoffFrequencyRamp.getTarget();
        case AKHighPassButterworthFilterParameterRampDuration:
            return data->cutoffFrequencyRamp.getRampDuration(sampleRate);
    }
    return 0;
}

void AKHighPassButterworthFilterDSP::init(int channelCount, double sampleRate) {
    AKSoundpipeDSPBase::init(channelCount, sampleRate);
    sp_buthp_create(&data->buthp0);
    sp_buthp_init(sp, data->buthp0);
    sp_buthp_create(&data->buthp1);
    sp_buthp_init(sp, data->buthp1);
    data->buthp0->freq = defaultCutoffFrequency;
    data->buthp1->freq = defaultCutoffFrequency;
}

void AKHighPassButterworthFilterDSP::deinit() {
    sp_buthp_destroy(&data->buthp0);
    sp_buthp_destroy(&data->buthp1);
}

void AKHighPassButterworthFilterDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);

        // do ramping every 8 samples
        if ((frameOffset & 0x7) == 0) {
            data->cutoffFrequencyRamp.advanceTo(now + frameOffset);
        }

        data->buthp0->freq = data->cutoffFrequencyRamp.getValue();
        data->buthp1->freq = data->cutoffFrequencyRamp.getValue();

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
                sp_buthp_compute(sp, data->buthp0, in, out);
            } else {
                sp_buthp_compute(sp, data->buthp1, in, out);
            }
        }
    }
}
