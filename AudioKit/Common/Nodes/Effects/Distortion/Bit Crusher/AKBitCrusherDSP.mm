//
//  AKBitCrusherDSP.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#include "AKBitCrusherDSP.hpp"
#import "AKLinearParameterRamp.hpp"

extern "C" void* createBitCrusherDSP(int nChannels, double sampleRate) {
    AKBitCrusherDSP* dsp = new AKBitCrusherDSP();
    dsp->init(nChannels, sampleRate);
    return dsp;
}

struct AKBitCrusherDSP::_Internal {
    sp_bitcrush *_bitcrush0;
    sp_bitcrush *_bitcrush1;
    AKLinearParameterRamp bitDepthRamp;
    AKLinearParameterRamp sampleRateRamp;
};

AKBitCrusherDSP::AKBitCrusherDSP() : _private(new _Internal) {
    _private->bitDepthRamp.setTarget(defaultBitDepth, true);
    _private->bitDepthRamp.setDurationInSamples(defaultRampDurationSamples);
    _private->sampleRateRamp.setTarget(defaultSampleRate, true);
    _private->sampleRateRamp.setDurationInSamples(defaultRampDurationSamples);
}

// Uses the ParameterAddress as a key
void AKBitCrusherDSP::setParameter(AUParameterAddress address, AUValue value, bool immediate) {
    switch (address) {
        case AKBitCrusherParameterBitDepth:
            _private->bitDepthRamp.setTarget(clamp(value, bitDepthLowerBound, bitDepthUpperBound), immediate);
            break;
        case AKBitCrusherParameterSampleRate:
            _private->sampleRateRamp.setTarget(clamp(value, sampleRateLowerBound, sampleRateUpperBound), immediate);
            break;
        case AKBitCrusherParameterRampDuration:
            _private->bitDepthRamp.setRampDuration(value, _sampleRate);
            _private->sampleRateRamp.setRampDuration(value, _sampleRate);
            break;
    }
}

// Uses the ParameterAddress as a key
float AKBitCrusherDSP::getParameter(uint64_t address) {
    switch (address) {
        case AKBitCrusherParameterBitDepth:
            return _private->bitDepthRamp.getTarget();
        case AKBitCrusherParameterSampleRate:
            return _private->sampleRateRamp.getTarget();
        case AKBitCrusherParameterRampDuration:
            return _private->bitDepthRamp.getRampDuration(_sampleRate);
    }
    return 0;
}

void AKBitCrusherDSP::init(int _channels, double _sampleRate) {
    AKSoundpipeDSPBase::init(_channels, _sampleRate);
    sp_bitcrush_create(&_private->_bitcrush0);
    sp_bitcrush_init(_sp, _private->_bitcrush0);
    sp_bitcrush_create(&_private->_bitcrush1);
    sp_bitcrush_init(_sp, _private->_bitcrush1);
    _private->_bitcrush0->bitdepth = defaultBitDepth;
    _private->_bitcrush1->bitdepth = defaultBitDepth;
    _private->_bitcrush0->srate = defaultSampleRate;
    _private->_bitcrush1->srate = defaultSampleRate;
}

void AKBitCrusherDSP::destroy() {
    sp_bitcrush_destroy(&_private->_bitcrush0);
    sp_bitcrush_destroy(&_private->_bitcrush1);
    AKSoundpipeDSPBase::destroy();
}

void AKBitCrusherDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);

        // do ramping every 8 samples
        if ((frameOffset & 0x7) == 0) {
            _private->bitDepthRamp.advanceTo(_now + frameOffset);
            _private->sampleRateRamp.advanceTo(_now + frameOffset);
        }

        _private->_bitcrush0->bitdepth = _private->bitDepthRamp.getValue();
        _private->_bitcrush1->bitdepth = _private->bitDepthRamp.getValue();
        _private->_bitcrush0->srate = _private->sampleRateRamp.getValue();
        _private->_bitcrush1->srate = _private->sampleRateRamp.getValue();

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
                sp_bitcrush_compute(_sp, _private->_bitcrush0, in, out);
            } else {
                sp_bitcrush_compute(_sp, _private->_bitcrush1, in, out);
            }
        }
    }
}
