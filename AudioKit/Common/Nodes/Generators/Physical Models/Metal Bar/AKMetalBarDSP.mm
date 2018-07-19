//
//  AKMetalBarDSP.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#include "AKMetalBarDSP.hpp"
#import "AKLinearParameterRamp.hpp"

extern "C" void* createMetalBarDSP(int nChannels, double sampleRate) {
    AKMetalBarDSP* dsp = new AKMetalBarDSP();
    dsp->init(nChannels, sampleRate);
    return dsp;
}

struct AKMetalBarDSP::_Internal {
    sp_bar *_bar;
    AKLinearParameterRamp leftBoundaryConditionRamp;
    AKLinearParameterRamp rightBoundaryConditionRamp;
    AKLinearParameterRamp decayDurationRamp;
    AKLinearParameterRamp scanSpeedRamp;
    AKLinearParameterRamp positionRamp;
    AKLinearParameterRamp strikeVelocityRamp;
    AKLinearParameterRamp strikeWidthRamp;
};

AKMetalBarDSP::AKMetalBarDSP() : _private(new _Internal) {
    _private->leftBoundaryConditionRamp.setTarget(defaultLeftBoundaryCondition, true);
    _private->leftBoundaryConditionRamp.setDurationInSamples(defaultRampDurationSamples);
    _private->rightBoundaryConditionRamp.setTarget(defaultRightBoundaryCondition, true);
    _private->rightBoundaryConditionRamp.setDurationInSamples(defaultRampDurationSamples);
    _private->decayDurationRamp.setTarget(defaultDecayDuration, true);
    _private->decayDurationRamp.setDurationInSamples(defaultRampDurationSamples);
    _private->scanSpeedRamp.setTarget(defaultScanSpeed, true);
    _private->scanSpeedRamp.setDurationInSamples(defaultRampDurationSamples);
    _private->positionRamp.setTarget(defaultPosition, true);
    _private->positionRamp.setDurationInSamples(defaultRampDurationSamples);
    _private->strikeVelocityRamp.setTarget(defaultStrikeVelocity, true);
    _private->strikeVelocityRamp.setDurationInSamples(defaultRampDurationSamples);
    _private->strikeWidthRamp.setTarget(defaultStrikeWidth, true);
    _private->strikeWidthRamp.setDurationInSamples(defaultRampDurationSamples);
}

// Uses the ParameterAddress as a key
void AKMetalBarDSP::setParameter(AUParameterAddress address, AUValue value, bool immediate) {
    switch (address) {
        case AKMetalBarParameterLeftBoundaryCondition:
            _private->leftBoundaryConditionRamp.setTarget(clamp(value, leftBoundaryConditionLowerBound, leftBoundaryConditionUpperBound), immediate);
            break;
        case AKMetalBarParameterRightBoundaryCondition:
            _private->rightBoundaryConditionRamp.setTarget(clamp(value, rightBoundaryConditionLowerBound, rightBoundaryConditionUpperBound), immediate);
            break;
        case AKMetalBarParameterDecayDuration:
            _private->decayDurationRamp.setTarget(clamp(value, decayDurationLowerBound, decayDurationUpperBound), immediate);
            break;
        case AKMetalBarParameterScanSpeed:
            _private->scanSpeedRamp.setTarget(clamp(value, scanSpeedLowerBound, scanSpeedUpperBound), immediate);
            break;
        case AKMetalBarParameterPosition:
            _private->positionRamp.setTarget(clamp(value, positionLowerBound, positionUpperBound), immediate);
            break;
        case AKMetalBarParameterStrikeVelocity:
            _private->strikeVelocityRamp.setTarget(clamp(value, strikeVelocityLowerBound, strikeVelocityUpperBound), immediate);
            break;
        case AKMetalBarParameterStrikeWidth:
            _private->strikeWidthRamp.setTarget(clamp(value, strikeWidthLowerBound, strikeWidthUpperBound), immediate);
            break;
        case AKMetalBarParameterRampDuration:
            _private->leftBoundaryConditionRamp.setRampDuration(value, _sampleRate);
            _private->rightBoundaryConditionRamp.setRampDuration(value, _sampleRate);
            _private->decayDurationRamp.setRampDuration(value, _sampleRate);
            _private->scanSpeedRamp.setRampDuration(value, _sampleRate);
            _private->positionRamp.setRampDuration(value, _sampleRate);
            _private->strikeVelocityRamp.setRampDuration(value, _sampleRate);
            _private->strikeWidthRamp.setRampDuration(value, _sampleRate);
            break;
    }
}

// Uses the ParameterAddress as a key
float AKMetalBarDSP::getParameter(uint64_t address) {
    switch (address) {
        case AKMetalBarParameterLeftBoundaryCondition:
            return _private->leftBoundaryConditionRamp.getTarget();
        case AKMetalBarParameterRightBoundaryCondition:
            return _private->rightBoundaryConditionRamp.getTarget();
        case AKMetalBarParameterDecayDuration:
            return _private->decayDurationRamp.getTarget();
        case AKMetalBarParameterScanSpeed:
            return _private->scanSpeedRamp.getTarget();
        case AKMetalBarParameterPosition:
            return _private->positionRamp.getTarget();
        case AKMetalBarParameterStrikeVelocity:
            return _private->strikeVelocityRamp.getTarget();
        case AKMetalBarParameterStrikeWidth:
            return _private->strikeWidthRamp.getTarget();
        case AKMetalBarParameterRampDuration:
            return _private->leftBoundaryConditionRamp.getRampDuration(_sampleRate);
    }
    return 0;
}

void AKMetalBarDSP::init(int _channels, double _sampleRate) {
    AKSoundpipeDSPBase::init(_channels, _sampleRate);
    sp_bar_create(&_private->_bar);
    sp_bar_init(_sp, _private->_bar, 3, 0.0001);
    _private->_bar->bcL = defaultLeftBoundaryCondition;
    _private->_bar->bcR = defaultRightBoundaryCondition;
    _private->_bar->T30 = defaultDecayDuration;
    _private->_bar->scan = defaultScanSpeed;
    _private->_bar->pos = defaultPosition;
    _private->_bar->vel = defaultStrikeVelocity;
    _private->_bar->wid = defaultStrikeWidth;
}

void AKMetalBarDSP::destroy() {
    sp_bar_destroy(&_private->_bar);
    AKSoundpipeDSPBase::destroy();
}

void AKMetalBarDSP::trigger() {
    internalTrigger = 1;
}

void AKMetalBarDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);

        // do ramping every 8 samples
        if ((frameOffset & 0x7) == 0) {
            _private->leftBoundaryConditionRamp.advanceTo(_now + frameOffset);
            _private->rightBoundaryConditionRamp.advanceTo(_now + frameOffset);
            _private->decayDurationRamp.advanceTo(_now + frameOffset);
            _private->scanSpeedRamp.advanceTo(_now + frameOffset);
            _private->positionRamp.advanceTo(_now + frameOffset);
            _private->strikeVelocityRamp.advanceTo(_now + frameOffset);
            _private->strikeWidthRamp.advanceTo(_now + frameOffset);
        }

        _private->_bar->bcL = _private->leftBoundaryConditionRamp.getValue();
        _private->_bar->bcR = _private->rightBoundaryConditionRamp.getValue();
        _private->_bar->T30 = _private->decayDurationRamp.getValue();
        _private->_bar->scan = _private->scanSpeedRamp.getValue();
        _private->_bar->pos = _private->positionRamp.getValue();
        _private->_bar->vel = _private->strikeVelocityRamp.getValue();
        _private->_bar->wid = _private->strikeWidthRamp.getValue();

        float temp = 0;
        for (int channel = 0; channel < _nChannels; ++channel) {
            float* out = (float *)_outBufferListPtr->mBuffers[channel].mData + frameOffset;

            if (_playing) {
                if (channel == 0) {
                    sp_bar_compute(_sp, _private->_bar, &internalTrigger, &temp);
                }
                *out = temp;
            } else {
                *out = 0.0;
            }
        }
    }
}
