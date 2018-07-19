//
//  AKPitchShifterDSP.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#include "AKPitchShifterDSP.hpp"
#import "AKLinearParameterRamp.hpp"

extern "C" void* createPitchShifterDSP(int nChannels, double sampleRate) {
    AKPitchShifterDSP* dsp = new AKPitchShifterDSP();
    dsp->init(nChannels, sampleRate);
    return dsp;
}

struct AKPitchShifterDSP::_Internal {
    sp_pshift *_pshift0;
    sp_pshift *_pshift1;
    AKLinearParameterRamp shiftRamp;
    AKLinearParameterRamp windowSizeRamp;
    AKLinearParameterRamp crossfadeRamp;
};

AKPitchShifterDSP::AKPitchShifterDSP() : _private(new _Internal) {
    _private->shiftRamp.setTarget(defaultShift, true);
    _private->shiftRamp.setDurationInSamples(defaultRampDurationSamples);
    _private->windowSizeRamp.setTarget(defaultWindowSize, true);
    _private->windowSizeRamp.setDurationInSamples(defaultRampDurationSamples);
    _private->crossfadeRamp.setTarget(defaultCrossfade, true);
    _private->crossfadeRamp.setDurationInSamples(defaultRampDurationSamples);
}

// Uses the ParameterAddress as a key
void AKPitchShifterDSP::setParameter(AUParameterAddress address, AUValue value, bool immediate) {
    switch (address) {
        case AKPitchShifterParameterShift:
            _private->shiftRamp.setTarget(clamp(value, shiftLowerBound, shiftUpperBound), immediate);
            break;
        case AKPitchShifterParameterWindowSize:
            _private->windowSizeRamp.setTarget(clamp(value, windowSizeLowerBound, windowSizeUpperBound), immediate);
            break;
        case AKPitchShifterParameterCrossfade:
            _private->crossfadeRamp.setTarget(clamp(value, crossfadeLowerBound, crossfadeUpperBound), immediate);
            break;
        case AKPitchShifterParameterRampDuration:
            _private->shiftRamp.setRampDuration(value, _sampleRate);
            _private->windowSizeRamp.setRampDuration(value, _sampleRate);
            _private->crossfadeRamp.setRampDuration(value, _sampleRate);
            break;
    }
}

// Uses the ParameterAddress as a key
float AKPitchShifterDSP::getParameter(uint64_t address) {
    switch (address) {
        case AKPitchShifterParameterShift:
            return _private->shiftRamp.getTarget();
        case AKPitchShifterParameterWindowSize:
            return _private->windowSizeRamp.getTarget();
        case AKPitchShifterParameterCrossfade:
            return _private->crossfadeRamp.getTarget();
        case AKPitchShifterParameterRampDuration:
            return _private->shiftRamp.getRampDuration(_sampleRate);
    }
    return 0;
}

void AKPitchShifterDSP::init(int _channels, double _sampleRate) {
    AKSoundpipeDSPBase::init(_channels, _sampleRate);
    sp_pshift_create(&_private->_pshift0);
    sp_pshift_init(_sp, _private->_pshift0);
    sp_pshift_create(&_private->_pshift1);
    sp_pshift_init(_sp, _private->_pshift1);
    *_private->_pshift0->shift = defaultShift;
    *_private->_pshift1->shift = defaultShift;
    *_private->_pshift0->window = defaultWindowSize;
    *_private->_pshift1->window = defaultWindowSize;
    *_private->_pshift0->xfade = defaultCrossfade;
    *_private->_pshift1->xfade = defaultCrossfade;
}

void AKPitchShifterDSP::destroy() {
    sp_pshift_destroy(&_private->_pshift0);
    sp_pshift_destroy(&_private->_pshift1);
    AKSoundpipeDSPBase::destroy();
}

void AKPitchShifterDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);

        // do ramping every 8 samples
        if ((frameOffset & 0x7) == 0) {
            _private->shiftRamp.advanceTo(_now + frameOffset);
            _private->windowSizeRamp.advanceTo(_now + frameOffset);
            _private->crossfadeRamp.advanceTo(_now + frameOffset);
        }

        *_private->_pshift0->shift = _private->shiftRamp.getValue();
        *_private->_pshift1->shift = _private->shiftRamp.getValue();
        *_private->_pshift0->window = _private->windowSizeRamp.getValue();
        *_private->_pshift1->window = _private->windowSizeRamp.getValue();
        *_private->_pshift0->xfade = _private->crossfadeRamp.getValue();
        *_private->_pshift1->xfade = _private->crossfadeRamp.getValue();

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
                sp_pshift_compute(_sp, _private->_pshift0, in, out);
            } else {
                sp_pshift_compute(_sp, _private->_pshift1, in, out);
            }
        }
    }
}
