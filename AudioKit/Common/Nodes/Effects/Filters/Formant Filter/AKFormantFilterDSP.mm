//
//  AKFormantFilterDSP.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2020 AudioKit. All rights reserved.
//

#include "AKFormantFilterDSP.hpp"
#include "AKLinearParameterRamp.hpp"

extern "C" AKDSPRef createFormantFilterDSP() {
    return new AKFormantFilterDSP();
}

struct AKFormantFilterDSP::InternalData {
    sp_fofilt *fofilt0;
    sp_fofilt *fofilt1;
    AKLinearParameterRamp centerFrequencyRamp;
    AKLinearParameterRamp attackDurationRamp;
    AKLinearParameterRamp decayDurationRamp;
};

AKFormantFilterDSP::AKFormantFilterDSP() : data(new InternalData) {
    parameters[AKFormantFilterParameterCenterFrequency] = &data->centerFrequencyRamp;
    parameters[AKFormantFilterParameterAttackDuration] = &data->attackDurationRamp;
    parameters[AKFormantFilterParameterDecayDuration] = &data->decayDurationRamp;
}

void AKFormantFilterDSP::init(int channelCount, double sampleRate) {
    AKSoundpipeDSPBase::init(channelCount, sampleRate);
    sp_fofilt_create(&data->fofilt0);
    sp_fofilt_init(sp, data->fofilt0);
    sp_fofilt_create(&data->fofilt1);
    sp_fofilt_init(sp, data->fofilt1);
}

void AKFormantFilterDSP::deinit() {
    AKSoundpipeDSPBase::deinit();
    sp_fofilt_destroy(&data->fofilt0);
    sp_fofilt_destroy(&data->fofilt1);
}

void AKFormantFilterDSP::reset() {
    AKSoundpipeDSPBase::reset();
    if (!isInitialized) return;
    sp_fofilt_init(sp, data->fofilt0);
    sp_fofilt_init(sp, data->fofilt1);
}

void AKFormantFilterDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);

        // do ramping every 8 samples
        if ((frameOffset & 0x7) == 0) {
            data->centerFrequencyRamp.advanceTo(now + frameOffset);
            data->attackDurationRamp.advanceTo(now + frameOffset);
            data->decayDurationRamp.advanceTo(now + frameOffset);
        }

        data->fofilt0->freq = data->centerFrequencyRamp.getValue();
        data->fofilt1->freq = data->centerFrequencyRamp.getValue();
        data->fofilt0->atk = data->attackDurationRamp.getValue();
        data->fofilt1->atk = data->attackDurationRamp.getValue();
        data->fofilt0->dec = data->decayDurationRamp.getValue();
        data->fofilt1->dec = data->decayDurationRamp.getValue();

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
                sp_fofilt_compute(sp, data->fofilt0, in, out);
            } else {
                sp_fofilt_compute(sp, data->fofilt1, in, out);
            }
        }
    }
}
