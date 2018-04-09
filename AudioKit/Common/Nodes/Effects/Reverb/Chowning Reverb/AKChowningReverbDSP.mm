//
//  AKChowningReverbDSP.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#include "AKChowningReverbDSP.hpp"
#import "AKLinearParameterRamp.hpp"

extern "C" void* createChowningReverbDSP(int nChannels, double sampleRate) {
    AKChowningReverbDSP* dsp = new AKChowningReverbDSP();
    dsp->init(nChannels, sampleRate);
    return dsp;
}

struct AKChowningReverbDSP::_Internal {
    sp_jcrev *_jcrev0;
    sp_jcrev *_jcrev1;
};

AKChowningReverbDSP::AKChowningReverbDSP() : _private(new _Internal) {}

void AKChowningReverbDSP::init(int _channels, double _sampleRate) {
    AKSoundpipeDSPBase::init(_channels, _sampleRate);
    sp_jcrev_create(&_private->_jcrev0);
    sp_jcrev_init(_sp, _private->_jcrev0);
    sp_jcrev_create(&_private->_jcrev1);
    sp_jcrev_init(_sp, _private->_jcrev1);
}

void AKChowningReverbDSP::destroy() {
    sp_jcrev_destroy(&_private->_jcrev0);
    sp_jcrev_destroy(&_private->_jcrev1);
    AKSoundpipeDSPBase::destroy();
}

void AKChowningReverbDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

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
                sp_jcrev_compute(_sp, _private->_jcrev0, in, out);
            } else {
                sp_jcrev_compute(_sp, _private->_jcrev1, in, out);
            }
        }
    }
}
