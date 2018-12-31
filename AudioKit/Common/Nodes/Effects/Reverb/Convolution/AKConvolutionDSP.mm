//
//  AKConvolutionDSP.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#include "AKConvolutionDSP.hpp"
#import "AKLinearParameterRamp.hpp"

extern "C" AKDSPRef createConvolutionDSP(int nChannels, double sampleRate) {
    AKConvolutionDSP *dsp = new AKConvolutionDSP();
    dsp->init(nChannels, sampleRate);
    return dsp;
}

struct AKConvolutionDSP::_Internal {
    sp_conv *conv0;
    sp_conv *conv1;

    sp_ftbl *ftbl;
    UInt32 ftbl_size = 4096;

    int partitionLength = 2048;
};

AKConvolutionDSP::AKConvolutionDSP() : _private(new _Internal) {}

void AKConvolutionDSP::init(int _channels, double _sampleRate) {
    AKSoundpipeDSPBase::init(_channels, _sampleRate);
}

void AKConvolutionDSP::setPartitionLength(int partLength) {
    _private->partitionLength = partLength;
}

void AKConvolutionDSP::setUpTable(float *table, UInt32 size) {
    _private->ftbl_size = size;
    sp_ftbl_create(_sp, &_private->ftbl, _private->ftbl_size);
    _private->ftbl->tbl = table;
}


void AKConvolutionDSP::initConvolutionEngine() {
    sp_conv_create(&_private->conv0);
    sp_conv_create(&_private->conv1);
    sp_conv_init(_sp, _private->conv0, _private->ftbl, (float)_private->partitionLength);
    sp_conv_init(_sp, _private->conv1, _private->ftbl, (float)_private->partitionLength);
}

void AKConvolutionDSP::deinit() {
    sp_conv_destroy(&_private->conv0);
    sp_conv_destroy(&_private->conv1);
}

void AKConvolutionDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);

        float *tmpin[2];
        float *tmpout[2];
        for (int channel = 0; channel < _nChannels; ++channel) {
            float *in  = (float *)_inBufferListPtr->mBuffers[channel].mData  + frameOffset;
            float *out = (float *)_outBufferListPtr->mBuffers[channel].mData + frameOffset;
            if (channel < 2) {
                tmpin[channel] = in;
                tmpout[channel] = out;
            }
            if (!_playing) {
                *out = *in;
                continue;
            }

            if (channel == 0) {
                sp_conv_compute(_sp, _private->conv0, in, out);
            } else {
                sp_conv_compute(_sp, _private->conv1, in, out);
            }
            *out = *out * 0.05; // Hack
        }
    }
}
