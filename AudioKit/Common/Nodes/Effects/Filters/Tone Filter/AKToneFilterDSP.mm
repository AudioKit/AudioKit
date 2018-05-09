//
//  AKToneFilterDSP.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#include "AKToneFilterDSP.hpp"
#import "AKLinearParameterRamp.hpp"

extern "C" void* createToneFilterDSP(int nChannels, double sampleRate) {
    AKToneFilterDSP* dsp = new AKToneFilterDSP();
    dsp->init(nChannels, sampleRate);
    return dsp;
}

struct AKToneFilterDSP::_Internal {
    sp_tone *_tone0;
    sp_tone *_tone1;
    AKLinearParameterRamp halfPowerPointRamp;
};

AKToneFilterDSP::AKToneFilterDSP() : _private(new _Internal) {
    _private->halfPowerPointRamp.setTarget(defaultHalfPowerPoint, true);
    _private->halfPowerPointRamp.setDurationInSamples(defaultRampDurationSamples);
}

// Uses the ParameterAddress as a key
void AKToneFilterDSP::setParameter(AUParameterAddress address, AUValue value, bool immediate) {
    switch (address) {
        case AKToneFilterParameterHalfPowerPoint:
            _private->halfPowerPointRamp.setTarget(clamp(value, halfPowerPointLowerBound, halfPowerPointUpperBound), immediate);
            break;
        case AKToneFilterParameterRampDuration:
            _private->halfPowerPointRamp.setRampDuration(value, _sampleRate);
            break;
    }
}

// Uses the ParameterAddress as a key
float AKToneFilterDSP::getParameter(uint64_t address) {
    switch (address) {
        case AKToneFilterParameterHalfPowerPoint:
            return _private->halfPowerPointRamp.getTarget();
        case AKToneFilterParameterRampDuration:
            return _private->halfPowerPointRamp.getRampDuration(_sampleRate);
    }
    return 0;
}

void AKToneFilterDSP::init(int _channels, double _sampleRate) {
    AKSoundpipeDSPBase::init(_channels, _sampleRate);
    sp_tone_create(&_private->_tone0);
    sp_tone_init(_sp, _private->_tone0);
    sp_tone_create(&_private->_tone1);
    sp_tone_init(_sp, _private->_tone1);
    _private->_tone0->hp = defaultHalfPowerPoint;
    _private->_tone1->hp = defaultHalfPowerPoint;
}

void AKToneFilterDSP::destroy() {
    sp_tone_destroy(&_private->_tone0);
    sp_tone_destroy(&_private->_tone1);
    AKSoundpipeDSPBase::destroy();
}

void AKToneFilterDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);

        // do ramping every 8 samples
        if ((frameOffset & 0x7) == 0) {
            _private->halfPowerPointRamp.advanceTo(_now + frameOffset);
        }

        _private->_tone0->hp = _private->halfPowerPointRamp.getValue();
        _private->_tone1->hp = _private->halfPowerPointRamp.getValue();

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
                sp_tone_compute(_sp, _private->_tone0, in, out);
            } else {
                sp_tone_compute(_sp, _private->_tone1, in, out);
            }
        }
    }
}
