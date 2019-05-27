//
//  AKLowPassButterworthFilterDSP.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#include "AKLowPassButterworthFilterDSP.hpp"
#import "AKLinearParameterRamp.hpp"

extern "C" AKDSPRef createLowPassButterworthFilterDSP(int channelCount, double sampleRate) {
    AKLowPassButterworthFilterDSP *dsp = new AKLowPassButterworthFilterDSP();
    dsp->init(channelCount, sampleRate);
    return dsp;
}

struct AKLowPassButterworthFilterDSP::InternalData {
    sp_butlp *butlp0;
    sp_butlp *butlp1;
    AKLinearParameterRamp cutoffFrequencyRamp;
};

AKLowPassButterworthFilterDSP::AKLowPassButterworthFilterDSP() : data(new InternalData) {
    data->cutoffFrequencyRamp.setTarget(defaultCutoffFrequency, true);
    data->cutoffFrequencyRamp.setDurationInSamples(defaultRampDurationSamples);
}

// Uses the ParameterAddress as a key
void AKLowPassButterworthFilterDSP::setParameter(AUParameterAddress address, AUValue value, bool immediate) {
    switch (address) {
        case AKLowPassButterworthFilterParameterCutoffFrequency:
            data->cutoffFrequencyRamp.setTarget(clamp(value, cutoffFrequencyLowerBound, cutoffFrequencyUpperBound), immediate);
            break;
        case AKLowPassButterworthFilterParameterRampDuration:
            data->cutoffFrequencyRamp.setRampDuration(value, sampleRate);
            break;
    }
}

// Uses the ParameterAddress as a key
float AKLowPassButterworthFilterDSP::getParameter(uint64_t address) {
    switch (address) {
        case AKLowPassButterworthFilterParameterCutoffFrequency:
            return data->cutoffFrequencyRamp.getTarget();
        case AKLowPassButterworthFilterParameterRampDuration:
            return data->cutoffFrequencyRamp.getRampDuration(sampleRate);
    }
    return 0;
}

void AKLowPassButterworthFilterDSP::init(int channelCount, double sampleRate) {
    AKSoundpipeDSPBase::init(channelCount, sampleRate);
    sp_butlp_create(&data->butlp0);
    sp_butlp_init(sp, data->butlp0);
    sp_butlp_create(&data->butlp1);
    sp_butlp_init(sp, data->butlp1);
    data->butlp0->freq = defaultCutoffFrequency;
    data->butlp1->freq = defaultCutoffFrequency;
}

void AKLowPassButterworthFilterDSP::deinit() {
    sp_butlp_destroy(&data->butlp0);
    sp_butlp_destroy(&data->butlp1);
}

void AKLowPassButterworthFilterDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);

        // do ramping every 8 samples
        if ((frameOffset & 0x7) == 0) {
            data->cutoffFrequencyRamp.advanceTo(now + frameOffset);
        }

        data->butlp0->freq = data->cutoffFrequencyRamp.getValue();
        data->butlp1->freq = data->cutoffFrequencyRamp.getValue();

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
                sp_butlp_compute(sp, data->butlp0, in, out);
            } else {
                sp_butlp_compute(sp, data->butlp1, in, out);
            }
        }
    }
}
