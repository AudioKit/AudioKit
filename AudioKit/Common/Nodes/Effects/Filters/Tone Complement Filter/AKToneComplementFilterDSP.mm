//
//  AKToneComplementFilterDSP.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#include "AKToneComplementFilterDSP.hpp"
#import "AKLinearParameterRamp.hpp"

extern "C" void* createToneComplementFilterDSP(int nChannels, double sampleRate) {
    AKToneComplementFilterDSP* dsp = new AKToneComplementFilterDSP();
    dsp->init(nChannels, sampleRate);
    return dsp;
}

struct AKToneComplementFilterDSP::_Internal {
    sp_atone *_atone0;
    sp_atone *_atone1;
    AKLinearParameterRamp halfPowerPointRamp;
};

AKToneComplementFilterDSP::AKToneComplementFilterDSP() : _private(new _Internal) {
    _private->halfPowerPointRamp.setTarget(defaultHalfPowerPoint, true);
    _private->halfPowerPointRamp.setDurationInSamples(defaultRampDurationSamples);
}

// Uses the ParameterAddress as a key
void AKToneComplementFilterDSP::setParameter(AUParameterAddress address, AUValue value, bool immediate) {
    switch (address) {
        case AKToneComplementFilterParameterHalfPowerPoint:
            _private->halfPowerPointRamp.setTarget(clamp(value, halfPowerPointLowerBound, halfPowerPointUpperBound), immediate);
            break;
        case AKToneComplementFilterParameterRampDuration:
            _private->halfPowerPointRamp.setRampDuration(value, _sampleRate);
            break;
    }
}

// Uses the ParameterAddress as a key
float AKToneComplementFilterDSP::getParameter(uint64_t address) {
    switch (address) {
        case AKToneComplementFilterParameterHalfPowerPoint:
            return _private->halfPowerPointRamp.getTarget();
        case AKToneComplementFilterParameterRampDuration:
            return _private->halfPowerPointRamp.getRampDuration(_sampleRate);
    }
    return 0;
}

void AKToneComplementFilterDSP::init(int _channels, double _sampleRate) {
    AKSoundpipeDSPBase::init(_channels, _sampleRate);
    sp_atone_create(&_private->_atone0);
    sp_atone_init(_sp, _private->_atone0);
    sp_atone_create(&_private->_atone1);
    sp_atone_init(_sp, _private->_atone1);
    _private->_atone0->hp = defaultHalfPowerPoint;
    _private->_atone1->hp = defaultHalfPowerPoint;
}

void AKToneComplementFilterDSP::destroy() {
    sp_atone_destroy(&_private->_atone0);
    sp_atone_destroy(&_private->_atone1);
    AKSoundpipeDSPBase::destroy();
}

void AKToneComplementFilterDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);

        // do ramping every 8 samples
        if ((frameOffset & 0x7) == 0) {
            _private->halfPowerPointRamp.advanceTo(_now + frameOffset);
        }

        _private->_atone0->hp = _private->halfPowerPointRamp.getValue();
        _private->_atone1->hp = _private->halfPowerPointRamp.getValue();

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
                sp_atone_compute(_sp, _private->_atone0, in, out);
            } else {
                sp_atone_compute(_sp, _private->_atone1, in, out);
            }
        }
    }
}
