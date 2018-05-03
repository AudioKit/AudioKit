//
//  AKAutoWahDSP.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#include "AKAutoWahDSP.hpp"
#import "AKLinearParameterRamp.hpp"

extern "C" void* createAutoWahDSP(int nChannels, double sampleRate) {
    AKAutoWahDSP* dsp = new AKAutoWahDSP();
    dsp->init(nChannels, sampleRate);
    return dsp;
}

struct AKAutoWahDSP::_Internal {
    sp_autowah *_autowah0;
    sp_autowah *_autowah1;
    AKLinearParameterRamp wahRamp;
    AKLinearParameterRamp mixRamp;
    AKLinearParameterRamp amplitudeRamp;
};

AKAutoWahDSP::AKAutoWahDSP() : _private(new _Internal) {
    _private->wahRamp.setTarget(defaultWah, true);
    _private->wahRamp.setDurationInSamples(defaultRampDurationSamples);
    _private->mixRamp.setTarget(defaultMix, true);
    _private->mixRamp.setDurationInSamples(defaultRampDurationSamples);
    _private->amplitudeRamp.setTarget(defaultAmplitude, true);
    _private->amplitudeRamp.setDurationInSamples(defaultRampDurationSamples);
}

// Uses the ParameterAddress as a key
void AKAutoWahDSP::setParameter(AUParameterAddress address, AUValue value, bool immediate) {
    switch (address) {
        case AKAutoWahParameterWah:
            _private->wahRamp.setTarget(clamp(value, wahLowerBound, wahUpperBound), immediate);
            break;
        case AKAutoWahParameterMix:
            _private->mixRamp.setTarget(clamp(value, mixLowerBound, mixUpperBound), immediate);
            break;
        case AKAutoWahParameterAmplitude:
            _private->amplitudeRamp.setTarget(clamp(value, amplitudeLowerBound, amplitudeUpperBound), immediate);
            break;
        case AKAutoWahParameterRampDuration:
            _private->wahRamp.setRampDuration(value, _sampleRate);
            _private->mixRamp.setRampDuration(value, _sampleRate);
            _private->amplitudeRamp.setRampDuration(value, _sampleRate);
            break;
    }
}

// Uses the ParameterAddress as a key
float AKAutoWahDSP::getParameter(uint64_t address) {
    switch (address) {
        case AKAutoWahParameterWah:
            return _private->wahRamp.getTarget();
        case AKAutoWahParameterMix:
            return _private->mixRamp.getTarget();
        case AKAutoWahParameterAmplitude:
            return _private->amplitudeRamp.getTarget();
        case AKAutoWahParameterRampDuration:
            return _private->wahRamp.getRampDuration(_sampleRate);
    }
    return 0;
}

void AKAutoWahDSP::init(int _channels, double _sampleRate) {
    AKSoundpipeDSPBase::init(_channels, _sampleRate);
    sp_autowah_create(&_private->_autowah0);
    sp_autowah_init(_sp, _private->_autowah0);
    sp_autowah_create(&_private->_autowah1);
    sp_autowah_init(_sp, _private->_autowah1);
    *_private->_autowah0->wah = defaultWah;
    *_private->_autowah1->wah = defaultWah;
    *_private->_autowah0->mix = defaultMix;
    *_private->_autowah1->mix = defaultMix;
    *_private->_autowah0->level = defaultAmplitude;
    *_private->_autowah1->level = defaultAmplitude;
}

void AKAutoWahDSP::destroy() {
    sp_autowah_destroy(&_private->_autowah0);
    sp_autowah_destroy(&_private->_autowah1);
    AKSoundpipeDSPBase::destroy();
}

void AKAutoWahDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);

        // do ramping every 8 samples
        if ((frameOffset & 0x7) == 0) {
            _private->wahRamp.advanceTo(_now + frameOffset);
            _private->mixRamp.advanceTo(_now + frameOffset);
            _private->amplitudeRamp.advanceTo(_now + frameOffset);
        }

        *_private->_autowah0->wah = _private->wahRamp.getValue();
        *_private->_autowah1->wah = _private->wahRamp.getValue();
        *_private->_autowah0->mix = _private->mixRamp.getValue() * 100;
        *_private->_autowah1->mix = _private->mixRamp.getValue() * 100;
        *_private->_autowah0->level = _private->amplitudeRamp.getValue();
        *_private->_autowah1->level = _private->amplitudeRamp.getValue();

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
                sp_autowah_compute(_sp, _private->_autowah0, in, out);
            } else {
                sp_autowah_compute(_sp, _private->_autowah1, in, out);
            }
        }
    }
}
