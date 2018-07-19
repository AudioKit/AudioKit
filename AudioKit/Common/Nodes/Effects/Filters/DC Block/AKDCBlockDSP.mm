//
//  AKDCBlockDSP.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#include "AKDCBlockDSP.hpp"
#import "AKLinearParameterRamp.hpp"

extern "C" void* createDCBlockDSP(int nChannels, double sampleRate) {
    AKDCBlockDSP* dsp = new AKDCBlockDSP();
    dsp->init(nChannels, sampleRate);
    return dsp;
}

struct AKDCBlockDSP::_Internal {
    sp_dcblock *_dcblock0;
    sp_dcblock *_dcblock1;
};

AKDCBlockDSP::AKDCBlockDSP() : _private(new _Internal) {}

void AKDCBlockDSP::init(int _channels, double _sampleRate) {
    AKSoundpipeDSPBase::init(_channels, _sampleRate);
    sp_dcblock_create(&_private->_dcblock0);
    sp_dcblock_init(_sp, _private->_dcblock0);
    sp_dcblock_create(&_private->_dcblock1);
    sp_dcblock_init(_sp, _private->_dcblock1);
}

void AKDCBlockDSP::destroy() {
    sp_dcblock_destroy(&_private->_dcblock0);
    sp_dcblock_destroy(&_private->_dcblock1);
    AKSoundpipeDSPBase::destroy();
}

void AKDCBlockDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);

        // do ramping every 8 samples
        if ((frameOffset & 0x7) == 0) {
        }


        float *tmpin[2];
        float *tmpout[2];
        for (int channel = 0; channel < _nChannels; ++channel) {
            float* in  = (float *)_inBufferListPtr->mBuffers[channel].mData  + frameOffset;
            float* out = (float *)_outBufferListPtr->mBuffers[channel].mData + frameOffset;
            if (channel < 2) {
                tmpin[channel] = in;
                tmpout[channel] = out;
            }
            if (!_playing) {
                *out = *in;
                continue;
            }

            if (channel == 0) {
                sp_dcblock_compute(_sp, _private->_dcblock0, in, out);
            } else {
                sp_dcblock_compute(_sp, _private->_dcblock1, in, out);
            }
        }
    }
}
