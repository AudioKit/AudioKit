//
//  AKLowPassButterworthFilterDSP.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2020 AudioKit. All rights reserved.
//

#include "AKLowPassButterworthFilterDSP.hpp"
#include "AKLinearParameterRamp.hpp"

extern "C" AKDSPRef createLowPassButterworthFilterDSP() {
    return new AKLowPassButterworthFilterDSP();
}

struct AKLowPassButterworthFilterDSP::InternalData {
    sp_butlp *butlp0;
    sp_butlp *butlp1;
    AKLinearParameterRamp cutoffFrequencyRamp;
};

AKLowPassButterworthFilterDSP::AKLowPassButterworthFilterDSP() : data(new InternalData) {
    parameters[AKLowPassButterworthFilterParameterCutoffFrequency] = &data->cutoffFrequencyRamp;
}

void AKLowPassButterworthFilterDSP::init(int channelCount, double sampleRate) {
    AKSoundpipeDSPBase::init(channelCount, sampleRate);
    sp_butlp_create(&data->butlp0);
    sp_butlp_init(sp, data->butlp0);
    sp_butlp_create(&data->butlp1);
    sp_butlp_init(sp, data->butlp1);
}

void AKLowPassButterworthFilterDSP::deinit() {
    AKSoundpipeDSPBase::deinit();
    sp_butlp_destroy(&data->butlp0);
    sp_butlp_destroy(&data->butlp1);
}

void AKLowPassButterworthFilterDSP::reset() {
    AKSoundpipeDSPBase::reset();
    if (!isInitialized) return;
    sp_butlp_init(sp, data->butlp0);
    sp_butlp_init(sp, data->butlp1);
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
