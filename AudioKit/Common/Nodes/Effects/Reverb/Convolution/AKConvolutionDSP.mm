// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "AKConvolutionDSP.hpp"
#include <vector>

extern "C" AKDSPRef createConvolutionDSP() {
    return new AKConvolutionDSP();
}

extern "C" void setPartitionLengthConvolutionDSP(AKDSPRef dsp, int length) {
    ((AKConvolutionDSP*)dsp)->setPartitionLength(length);
}

struct AKConvolutionDSP::InternalData {
    sp_conv *conv0;
    sp_conv *conv1;
    sp_ftbl *ftbl;
    std::vector<float> wavetable;

    int partitionLength = 2048;
};

AKConvolutionDSP::AKConvolutionDSP() : data(new InternalData) {
}

void AKConvolutionDSP::init(int channelCount, double sampleRate) {
    AKSoundpipeDSPBase::init(channelCount, sampleRate);
    sp_ftbl_create(sp, &data->ftbl, data->wavetable.size());
    std::copy(data->wavetable.cbegin(), data->wavetable.cend(), data->ftbl->tbl);
    sp_conv_create(&data->conv0);
    sp_conv_init(sp, data->conv0, data->ftbl, (float)data->partitionLength);
    sp_conv_create(&data->conv1);
    sp_conv_init(sp, data->conv1, data->ftbl, (float)data->partitionLength);
}

void AKConvolutionDSP::setPartitionLength(int partLength) {
    data->partitionLength = partLength;
    reset();
}

void AKConvolutionDSP::setWavetable(const float *table, size_t length, int index) {
    data->wavetable = std::vector<float>(table, table + length);
    reset();
}

void AKConvolutionDSP::deinit() {
    AKSoundpipeDSPBase::deinit();
    sp_conv_destroy(&data->conv0);
    sp_conv_destroy(&data->conv1);
}

void AKConvolutionDSP::reset() {
    AKSoundpipeDSPBase::reset();
    if (!isInitialized) return;
    sp_conv_init(sp, data->conv0, data->ftbl, (float)data->partitionLength);
    sp_conv_init(sp, data->conv1, data->ftbl, (float)data->partitionLength);
}

void AKConvolutionDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

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
                sp_conv_compute(sp, data->conv0, in, out);
            } else {
                sp_conv_compute(sp, data->conv1, in, out);
            }
            *out = *out * 0.05; // Hack
        }
    }
}
