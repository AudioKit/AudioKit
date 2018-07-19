//
//  AKClipperDSP.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#include "AKClipperDSP.hpp"
#import "AKLinearParameterRamp.hpp"

extern "C" void* createClipperDSP(int nChannels, double sampleRate) {
    AKClipperDSP* dsp = new AKClipperDSP();
    dsp->init(nChannels, sampleRate);
    return dsp;
}

struct AKClipperDSP::_Internal {
    sp_clip *_clip0;
    sp_clip *_clip1;
    AKLinearParameterRamp limitRamp;
};

AKClipperDSP::AKClipperDSP() : _private(new _Internal) {
    _private->limitRamp.setTarget(defaultLimit, true);
    _private->limitRamp.setDurationInSamples(defaultRampDurationSamples);
}

// Uses the ParameterAddress as a key
void AKClipperDSP::setParameter(AUParameterAddress address, AUValue value, bool immediate) {
    switch (address) {
        case AKClipperParameterLimit:
            _private->limitRamp.setTarget(clamp(value, limitLowerBound, limitUpperBound), immediate);
            break;
        case AKClipperParameterRampDuration:
            _private->limitRamp.setRampDuration(value, _sampleRate);
            break;
    }
}

// Uses the ParameterAddress as a key
float AKClipperDSP::getParameter(uint64_t address) {
    switch (address) {
        case AKClipperParameterLimit:
            return _private->limitRamp.getTarget();
        case AKClipperParameterRampDuration:
            return _private->limitRamp.getRampDuration(_sampleRate);
    }
    return 0;
}

void AKClipperDSP::init(int _channels, double _sampleRate) {
    AKSoundpipeDSPBase::init(_channels, _sampleRate);
    sp_clip_create(&_private->_clip0);
    sp_clip_init(_sp, _private->_clip0);
    sp_clip_create(&_private->_clip1);
    sp_clip_init(_sp, _private->_clip1);
    _private->_clip0->lim = defaultLimit;
    _private->_clip1->lim = defaultLimit;
}

void AKClipperDSP::destroy() {
    sp_clip_destroy(&_private->_clip0);
    sp_clip_destroy(&_private->_clip1);
    AKSoundpipeDSPBase::destroy();
}

void AKClipperDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);

        // do ramping every 8 samples
        if ((frameOffset & 0x7) == 0) {
            _private->limitRamp.advanceTo(_now + frameOffset);
        }

        _private->_clip0->lim = _private->limitRamp.getValue();
        _private->_clip1->lim = _private->limitRamp.getValue();

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
                sp_clip_compute(_sp, _private->_clip0, in, out);
            } else {
                sp_clip_compute(_sp, _private->_clip1, in, out);
            }
        }
    }
}
