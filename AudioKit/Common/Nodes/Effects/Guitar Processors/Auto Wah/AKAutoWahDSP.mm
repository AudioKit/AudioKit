//
//  AKAutoWahDSP.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2020 AudioKit. All rights reserved.
//

#include "AKAutoWahDSP.hpp"
#include "AKLinearParameterRamp.hpp"

extern "C" AKDSPRef createAutoWahDSP() {
    return new AKAutoWahDSP();
}

struct AKAutoWahDSP::InternalData {
    sp_autowah *autowah0;
    sp_autowah *autowah1;
    AKLinearParameterRamp wahRamp;
    AKLinearParameterRamp mixRamp;
    AKLinearParameterRamp amplitudeRamp;
};

AKAutoWahDSP::AKAutoWahDSP() : data(new InternalData) {
    parameters[AKAutoWahParameterWah] = &data->wahRamp;
    parameters[AKAutoWahParameterMix] = &data->mixRamp;
    parameters[AKAutoWahParameterAmplitude] = &data->amplitudeRamp;
}

void AKAutoWahDSP::init(int channelCount, double sampleRate) {
    AKSoundpipeDSPBase::init(channelCount, sampleRate);
    sp_autowah_create(&data->autowah0);
    sp_autowah_init(sp, data->autowah0);
    sp_autowah_create(&data->autowah1);
    sp_autowah_init(sp, data->autowah1);
}

void AKAutoWahDSP::deinit() {
    AKSoundpipeDSPBase::deinit();
    sp_autowah_destroy(&data->autowah0);
    sp_autowah_destroy(&data->autowah1);
}

void AKAutoWahDSP::reset() {
    AKSoundpipeDSPBase::reset();
    if (!isInitialized) return;
    sp_autowah_init(sp, data->autowah0);
    sp_autowah_init(sp, data->autowah1);
}

void AKAutoWahDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);

        // do ramping every 8 samples
        if ((frameOffset & 0x7) == 0) {
            data->wahRamp.advanceTo(now + frameOffset);
            data->mixRamp.advanceTo(now + frameOffset);
            data->amplitudeRamp.advanceTo(now + frameOffset);
        }

        *data->autowah0->wah = data->wahRamp.getValue();
        *data->autowah1->wah = data->wahRamp.getValue();
        *data->autowah0->mix = data->mixRamp.getValue() * 100;
        *data->autowah1->mix = data->mixRamp.getValue() * 100;
        *data->autowah0->level = data->amplitudeRamp.getValue();
        *data->autowah1->level = data->amplitudeRamp.getValue();

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
                sp_autowah_compute(sp, data->autowah0, in, out);
            } else {
                sp_autowah_compute(sp, data->autowah1, in, out);
            }
        }
    }
}
