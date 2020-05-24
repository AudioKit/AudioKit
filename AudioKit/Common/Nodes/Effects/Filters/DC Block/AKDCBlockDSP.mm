// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "AKDCBlockDSP.hpp"

extern "C" AKDSPRef createDCBlockDSP() {
    return new AKDCBlockDSP();
}

struct AKDCBlockDSP::InternalData {
    sp_dcblock *dcblock0;
    sp_dcblock *dcblock1;
};

AKDCBlockDSP::AKDCBlockDSP() : data(new InternalData) {
}

void AKDCBlockDSP::init(int channelCount, double sampleRate) {
    AKSoundpipeDSPBase::init(channelCount, sampleRate);
    sp_dcblock_create(&data->dcblock0);
    sp_dcblock_init(sp, data->dcblock0);
    sp_dcblock_create(&data->dcblock1);
    sp_dcblock_init(sp, data->dcblock1);
}

void AKDCBlockDSP::deinit() {
    AKSoundpipeDSPBase::deinit();
    sp_dcblock_destroy(&data->dcblock0);
    sp_dcblock_destroy(&data->dcblock1);
}

void AKDCBlockDSP::reset() {
    AKSoundpipeDSPBase::reset();
    if (!isInitialized) return;
    sp_dcblock_init(sp, data->dcblock0);
    sp_dcblock_init(sp, data->dcblock1);
}

void AKDCBlockDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);

        float *tmpin[2];
        float *tmpout[2];
        for (int channel = 0; channel < channelCount; ++channel) {
            float *in  = (float *)inputBufferLists[0]->mBuffers[channel].mData  + frameOffset;
            float *out = (float *)outputBufferLists[0]->mBuffers[channel].mData + frameOffset;
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
