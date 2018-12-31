//
//  AKConvolutionDSP.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#include "AKConvolutionDSP.hpp"
#import "AKLinearParameterRamp.hpp"

extern "C" AKDSPRef createConvolutionDSP(int channelCount, double sampleRate) {
    AKConvolutionDSP *dsp = new AKConvolutionDSP();
    dsp->init(channelCount, sampleRate);
    return dsp;
}

struct AKConvolutionDSP::InternalData {
    sp_conv *conv0;
    sp_conv *conv1;

    sp_ftbl *ftbl;
    UInt32 ftbl_size = 4096;

    int partitionLength = 2048;
};

AKConvolutionDSP::AKConvolutionDSP() : data(new InternalData) {}

void AKConvolutionDSP::init(int channelCount, double sampleRate) {
    AKSoundpipeDSPBase::init(channelCount, sampleRate);
}

void AKConvolutionDSP::setPartitionLength(int partLength) {
    data->partitionLength = partLength;
}

void AKConvolutionDSP::setUpTable(float *table, UInt32 size) {
    data->ftbl_size = size;
    sp_ftbl_create(sp, &data->ftbl, data->ftbl_size);
    data->ftbl->tbl = table;
}


void AKConvolutionDSP::initConvolutionEngine() {
    sp_conv_create(&data->conv0);
    sp_conv_create(&data->conv1);
    sp_conv_init(sp, data->conv0, data->ftbl, (float)data->partitionLength);
    sp_conv_init(sp, data->conv1, data->ftbl, (float)data->partitionLength);
}

void AKConvolutionDSP::deinit() {
    sp_conv_destroy(&data->conv0);
    sp_conv_destroy(&data->conv1);
}

void AKConvolutionDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

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
                sp_conv_compute(sp, data->conv0, in, out);
            } else {
                sp_conv_compute(sp, data->conv1, in, out);
            }
            *out = *out * 0.05; // Hack
        }
    }
}
