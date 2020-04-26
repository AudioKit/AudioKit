//
//  AKCombFilterReverbDSP.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2020 AudioKit. All rights reserved.
//

#include "AKCombFilterReverbDSP.hpp"
#include "AKLinearParameterRamp.hpp"

extern "C" AKDSPRef createCombFilterReverbDSP() {
    return new AKCombFilterReverbDSP();
}

struct AKCombFilterReverbDSP::InternalData {
    sp_comb *comb0;
    sp_comb *comb1;
    float loopDuration = 0.1;
    AKLinearParameterRamp reverbDurationRamp;
};

AKCombFilterReverbDSP::AKCombFilterReverbDSP() : data(new InternalData) {
    parameters[AKCombFilterReverbParameterReverbDuration] = &data->reverbDurationRamp;
}

void AKCombFilterReverbDSP::init(int channelCount, double sampleRate) {
    AKSoundpipeDSPBase::init(channelCount, sampleRate);
    sp_comb_create(&data->comb0);
    sp_comb_init(sp, data->comb0, data->loopDuration);
    sp_comb_create(&data->comb1);
    sp_comb_init(sp, data->comb1, data->loopDuration);
}

void AKCombFilterReverbDSP::deinit() {
    AKSoundpipeDSPBase::deinit();
    sp_comb_destroy(&data->comb0);
    sp_comb_destroy(&data->comb1);
}

void AKCombFilterReverbDSP::reset() {
    AKSoundpipeDSPBase::reset();
    if (!isStarted) return;
    sp_comb_init(sp, data->comb0, data->loopDuration);
    sp_comb_init(sp, data->comb1, data->loopDuration);
}

void AKCombFilterReverbDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);

        // do ramping every 8 samples
        if ((frameOffset & 0x7) == 0) {
            data->reverbDurationRamp.advanceTo(now + frameOffset);
        }

        data->comb0->revtime = data->reverbDurationRamp.getValue();
        data->comb1->revtime = data->reverbDurationRamp.getValue();

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
                sp_comb_compute(sp, data->comb0, in, out);
            } else {
                sp_comb_compute(sp, data->comb1, in, out);
            }
        }
    }
}
