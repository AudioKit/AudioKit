//
//  AKMetalBarDSP.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#include "AKMetalBarDSP.hpp"
#import "AKLinearParameterRamp.hpp"

extern "C" AKDSPRef createMetalBarDSP(int nChannels, double sampleRate) {
    AKMetalBarDSP *dsp = new AKMetalBarDSP();
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

AKMetalBarDSP::AKMetalBarDSP() : data(new _Internal) {
    data->leftBoundaryConditionRamp.setTarget(defaultLeftBoundaryCondition, true);
    data->leftBoundaryConditionRamp.setDurationInSamples(defaultRampDurationSamples);
    data->rightBoundaryConditionRamp.setTarget(defaultRightBoundaryCondition, true);
    data->rightBoundaryConditionRamp.setDurationInSamples(defaultRampDurationSamples);
    data->decayDurationRamp.setTarget(defaultDecayDuration, true);
    data->decayDurationRamp.setDurationInSamples(defaultRampDurationSamples);
    data->scanSpeedRamp.setTarget(defaultScanSpeed, true);
    data->scanSpeedRamp.setDurationInSamples(defaultRampDurationSamples);
    data->positionRamp.setTarget(defaultPosition, true);
    data->positionRamp.setDurationInSamples(defaultRampDurationSamples);
    data->strikeVelocityRamp.setTarget(defaultStrikeVelocity, true);
    data->strikeVelocityRamp.setDurationInSamples(defaultRampDurationSamples);
    data->strikeWidthRamp.setTarget(defaultStrikeWidth, true);
    data->strikeWidthRamp.setDurationInSamples(defaultRampDurationSamples);
}

// Uses the ParameterAddress as a key
void AKMetalBarDSP::setParameter(AUParameterAddress address, AUValue value, bool immediate) {
    switch (address) {
        case AKMetalBarParameterLeftBoundaryCondition:
            data->leftBoundaryConditionRamp.setTarget(clamp(value, leftBoundaryConditionLowerBound, leftBoundaryConditionUpperBound), immediate);
            break;
        case AKMetalBarParameterRightBoundaryCondition:
            data->rightBoundaryConditionRamp.setTarget(clamp(value, rightBoundaryConditionLowerBound, rightBoundaryConditionUpperBound), immediate);
            break;
        case AKMetalBarParameterDecayDuration:
            data->decayDurationRamp.setTarget(clamp(value, decayDurationLowerBound, decayDurationUpperBound), immediate);
            break;
        case AKMetalBarParameterScanSpeed:
            data->scanSpeedRamp.setTarget(clamp(value, scanSpeedLowerBound, scanSpeedUpperBound), immediate);
            break;
        case AKMetalBarParameterPosition:
            data->positionRamp.setTarget(clamp(value, positionLowerBound, positionUpperBound), immediate);
            break;
        case AKMetalBarParameterStrikeVelocity:
            data->strikeVelocityRamp.setTarget(clamp(value, strikeVelocityLowerBound, strikeVelocityUpperBound), immediate);
            break;
        case AKMetalBarParameterStrikeWidth:
            data->strikeWidthRamp.setTarget(clamp(value, strikeWidthLowerBound, strikeWidthUpperBound), immediate);
            break;
        case AKMetalBarParameterRampDuration:
            data->leftBoundaryConditionRamp.setRampDuration(value, _sampleRate);
            data->rightBoundaryConditionRamp.setRampDuration(value, _sampleRate);
            data->decayDurationRamp.setRampDuration(value, _sampleRate);
            data->scanSpeedRamp.setRampDuration(value, _sampleRate);
            data->positionRamp.setRampDuration(value, _sampleRate);
            data->strikeVelocityRamp.setRampDuration(value, _sampleRate);
            data->strikeWidthRamp.setRampDuration(value, _sampleRate);
            break;
    }
}

// Uses the ParameterAddress as a key
float AKMetalBarDSP::getParameter(uint64_t address) {
    switch (address) {
        case AKMetalBarParameterLeftBoundaryCondition:
            return data->leftBoundaryConditionRamp.getTarget();
        case AKMetalBarParameterRightBoundaryCondition:
            return data->rightBoundaryConditionRamp.getTarget();
        case AKMetalBarParameterDecayDuration:
            return data->decayDurationRamp.getTarget();
        case AKMetalBarParameterScanSpeed:
            return data->scanSpeedRamp.getTarget();
        case AKMetalBarParameterPosition:
            return data->positionRamp.getTarget();
        case AKMetalBarParameterStrikeVelocity:
            return data->strikeVelocityRamp.getTarget();
        case AKMetalBarParameterStrikeWidth:
            return data->strikeWidthRamp.getTarget();
        case AKMetalBarParameterRampDuration:
            return data->leftBoundaryConditionRamp.getRampDuration(_sampleRate);
    }
    return 0;
}

void AKMetalBarDSP::init(int _channels, double _sampleRate) {
    AKSoundpipeDSPBase::init(_channels, _sampleRate);
    sp_bar_create(&data->_bar);
    sp_bar_init(_sp, data->_bar, 3, 0.0001);
    data->_bar->bcL = defaultLeftBoundaryCondition;
    data->_bar->bcR = defaultRightBoundaryCondition;
    data->_bar->T30 = defaultDecayDuration;
    data->_bar->scan = defaultScanSpeed;
    data->_bar->pos = defaultPosition;
    data->_bar->vel = defaultStrikeVelocity;
    data->_bar->wid = defaultStrikeWidth;
}

void AKMetalBarDSP::deinit() {
    sp_bar_destroy(&data->_bar);
}

void AKMetalBarDSP::trigger() {
    internalTrigger = 1;
}

void AKMetalBarDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);

        // do ramping every 8 samples
        if ((frameOffset & 0x7) == 0) {
            data->leftBoundaryConditionRamp.advanceTo(_now + frameOffset);
            data->rightBoundaryConditionRamp.advanceTo(_now + frameOffset);
            data->decayDurationRamp.advanceTo(_now + frameOffset);
            data->scanSpeedRamp.advanceTo(_now + frameOffset);
            data->positionRamp.advanceTo(_now + frameOffset);
            data->strikeVelocityRamp.advanceTo(_now + frameOffset);
            data->strikeWidthRamp.advanceTo(_now + frameOffset);
        }

        data->_bar->bcL = data->leftBoundaryConditionRamp.getValue();
        data->_bar->bcR = data->rightBoundaryConditionRamp.getValue();
        data->_bar->T30 = data->decayDurationRamp.getValue();
        data->_bar->scan = data->scanSpeedRamp.getValue();
        data->_bar->pos = data->positionRamp.getValue();
        data->_bar->vel = data->strikeVelocityRamp.getValue();
        data->_bar->wid = data->strikeWidthRamp.getValue();

        float temp = 0;
        for (int channel = 0; channel < _nChannels; ++channel) {
            float *out = (float *)_outBufferListPtr->mBuffers[channel].mData + frameOffset;

            if (_playing) {
                if (channel == 0) {
                    sp_bar_compute(_sp, data->_bar, &internalTrigger, &temp);
                }
                *out = temp;
            } else {
                *out = 0.0;
            }
        }
    }
}
