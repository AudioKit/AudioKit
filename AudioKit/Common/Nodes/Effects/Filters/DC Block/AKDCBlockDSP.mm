//
//  AKDCBlockDSP.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#include "AKDCBlockDSP.hpp"

extern "C" AKDSPRef createDCBlockDSP(int channelCount, double sampleRate) {
    AKDCBlockDSP *dsp = new AKDCBlockDSP();
    dsp->init(channelCount, sampleRate);
    return dsp;
}

struct AKDCBlockDSP::InternalData {
    sp_dcblock *dcblock0;
    sp_dcblock *dcblock1;
};

AKDCBlockDSP::AKDCBlockDSP() : data(new InternalData) {}

void AKDCBlockDSP::init(int channelCount, double sampleRate) {
    AKSoundpipeDSPBase::init(channelCount, sampleRate);
    sp_dcblock_create(&data->dcblock0);
    sp_dcblock_init(sp, data->dcblock0);
    sp_dcblock_create(&data->dcblock1);
    sp_dcblock_init(sp, data->dcblock1);
}

void AKDCBlockDSP::deinit() {
    sp_dcblock_destroy(&data->dcblock0);
    sp_dcblock_destroy(&data->dcblock1);
}

void AKDCBlockDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);

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
                sp_dcblock_compute(sp, data->dcblock0, in, out);
            } else {
                sp_dcblock_compute(sp, data->dcblock1, in, out);
            }
        }
    }
}
