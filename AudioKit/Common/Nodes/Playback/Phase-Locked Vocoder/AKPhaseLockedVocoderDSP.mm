//
//  AKPhaseLockedVocoderDSP.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#include "AKPhaseLockedVocoderDSP.hpp"
#import "AKLinearParameterRamp.hpp"

extern "C" AKDSPRef createPhaseLockedVocoderDSP(int nChannels, double sampleRate) {
    AKPhaseLockedVocoderDSP *dsp = new AKPhaseLockedVocoderDSP();
    dsp->init(nChannels, sampleRate);
    return dsp;
}

struct AKPhaseLockedVocoderDSP::_Internal {
    sp_mincer *mincer;
    sp_ftbl *ftbl;
    UInt32 ftbl_size = 4096;

    AKLinearParameterRamp positionRamp;
    AKLinearParameterRamp amplitudeRamp;
    AKLinearParameterRamp pitchRatioRamp;
};

void AKPhaseLockedVocoderDSP::start() {
    AKSoundpipeDSPBase::start();
    sp_mincer_init(_sp, _private->mincer, _private->ftbl, 2048);
    _private->mincer->time = defaultPosition;
    _private->mincer->amp = defaultAmplitude;
    _private->mincer->pitch = defaultPitchRatio;
}

AKPhaseLockedVocoderDSP::AKPhaseLockedVocoderDSP() : _private(new _Internal) {
}

// Uses the ParameterAddress as a key
void AKPhaseLockedVocoderDSP::setParameter(AUParameterAddress address, AUValue value, bool immediate) {
    switch (address) {
        case AKPhaseLockedVocoderParameterPosition:
            _private->positionRamp.setTarget(clamp(value, positionLowerBound, positionUpperBound), immediate);
            break;
        case AKPhaseLockedVocoderParameterAmplitude:
            _private->amplitudeRamp.setTarget(clamp(value, amplitudeLowerBound, amplitudeUpperBound), immediate);
            break;
        case AKPhaseLockedVocoderParameterPitchRatio:
            _private->pitchRatioRamp.setTarget(clamp(value, pitchRatioLowerBound, pitchRatioUpperBound), immediate);
            break;
        case AKPhaseLockedVocoderParameterRampDuration:
            _private->positionRamp.setRampDuration(value, _sampleRate);
            _private->amplitudeRamp.setRampDuration(value, _sampleRate);
            _private->pitchRatioRamp.setRampDuration(value, _sampleRate);
            break;
    }
}

// Uses the ParameterAddress as a key
float AKPhaseLockedVocoderDSP::getParameter(uint64_t address) {
    switch (address) {
        case AKPhaseLockedVocoderParameterPosition:
            return _private->positionRamp.getTarget();
        case AKPhaseLockedVocoderParameterAmplitude:
            return _private->amplitudeRamp.getTarget();
        case AKPhaseLockedVocoderParameterPitchRatio:
            return _private->pitchRatioRamp.getTarget();
        case AKPhaseLockedVocoderParameterRampDuration:
            return _private->positionRamp.getRampDuration(_sampleRate);
    }
    return 0;
}

void AKPhaseLockedVocoderDSP::init(int _channels, double _sampleRate) {
    AKSoundpipeDSPBase::init(_channels, _sampleRate);
    sp_mincer_create(&_private->mincer);
}

void AKPhaseLockedVocoderDSP::setUpTable(float *table, UInt32 size) {
    _private->ftbl_size = size;
    sp_ftbl_create(_sp, &_private->ftbl, _private->ftbl_size);
    _private->ftbl->tbl = table;
}

void AKPhaseLockedVocoderDSP::deinit() {
    sp_ftbl_destroy(&_private->ftbl);
    sp_mincer_destroy(&_private->mincer);
}

void AKPhaseLockedVocoderDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);

        // do ramping every 8 samples
        if ((frameOffset & 0x7) == 0) {
            _private->positionRamp.advanceTo(_now + frameOffset);
            _private->amplitudeRamp.advanceTo(_now + frameOffset);
            _private->pitchRatioRamp.advanceTo(_now + frameOffset);
        }

        _private->mincer->time = _private->positionRamp.getValue();
        _private->mincer->amp = _private->amplitudeRamp.getValue();
        _private->mincer->pitch = _private->pitchRatioRamp.getValue();

        float *outL = (float *)_outBufferListPtr->mBuffers[0].mData  + frameOffset;
        float *outR = (float *)_outBufferListPtr->mBuffers[1].mData + frameOffset;
        if (_playing) {
            sp_mincer_compute(_sp, _private->mincer, NULL, outL);
            *outR = *outL;
        } else {
            *outL = 0;
            *outR = 0;
        }
    }
}
