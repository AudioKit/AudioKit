//
//  AKMetalBarDSP.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#include "AKMetalBarDSP.hpp"
#import "AKLinearParameterRamp.hpp"

extern "C" AKDSPRef createMetalBarDSP(int channelCount, double sampleRate) {
    AKMetalBarDSP *dsp = new AKMetalBarDSP();
    dsp->init(channelCount, sampleRate);
    return dsp;
}

struct AKMetalBarDSP::InternalData {
    sp_bar *bar;
    AKLinearParameterRamp leftBoundaryConditionRamp;
    AKLinearParameterRamp rightBoundaryConditionRamp;
    AKLinearParameterRamp decayDurationRamp;
    AKLinearParameterRamp scanSpeedRamp;
    AKLinearParameterRamp positionRamp;
    AKLinearParameterRamp strikeVelocityRamp;
    AKLinearParameterRamp strikeWidthRamp;
};

AKMetalBarDSP::AKMetalBarDSP() : data(new InternalData) {
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
            data->leftBoundaryConditionRamp.setRampDuration(value, sampleRate);
            data->rightBoundaryConditionRamp.setRampDuration(value, sampleRate);
            data->decayDurationRamp.setRampDuration(value, sampleRate);
            data->scanSpeedRamp.setRampDuration(value, sampleRate);
            data->positionRamp.setRampDuration(value, sampleRate);
            data->strikeVelocityRamp.setRampDuration(value, sampleRate);
            data->strikeWidthRamp.setRampDuration(value, sampleRate);
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
            return data->leftBoundaryConditionRamp.getRampDuration(sampleRate);
    }
    return 0;
}

void AKMetalBarDSP::init(int channelCount, double sampleRate) {
    AKSoundpipeDSPBase::init(channelCount, sampleRate);
    sp_bar_create(&data->bar);
    sp_bar_init(sp, data->bar, 3, 0.0001);
    data->bar->bcL = defaultLeftBoundaryCondition;
    data->bar->bcR = defaultRightBoundaryCondition;
    data->bar->T30 = defaultDecayDuration;
    data->bar->scan = defaultScanSpeed;
    data->bar->pos = defaultPosition;
    data->bar->vel = defaultStrikeVelocity;
    data->bar->wid = defaultStrikeWidth;
}

void AKMetalBarDSP::deinit() {
    sp_bar_destroy(&data->bar);
}

void AKMetalBarDSP::trigger() {
    internalTrigger = 1;
}

void AKMetalBarDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);

        // do ramping every 8 samples
        if ((frameOffset & 0x7) == 0) {
            data->leftBoundaryConditionRamp.advanceTo(now + frameOffset);
            data->rightBoundaryConditionRamp.advanceTo(now + frameOffset);
            data->decayDurationRamp.advanceTo(now + frameOffset);
            data->scanSpeedRamp.advanceTo(now + frameOffset);
            data->positionRamp.advanceTo(now + frameOffset);
            data->strikeVelocityRamp.advanceTo(now + frameOffset);
            data->strikeWidthRamp.advanceTo(now + frameOffset);
        }

        data->bar->bcL = data->leftBoundaryConditionRamp.getValue();
        data->bar->bcR = data->rightBoundaryConditionRamp.getValue();
        data->bar->T30 = data->decayDurationRamp.getValue();
        data->bar->scan = data->scanSpeedRamp.getValue();
        data->bar->pos = data->positionRamp.getValue();
        data->bar->vel = data->strikeVelocityRamp.getValue();
        data->bar->wid = data->strikeWidthRamp.getValue();

        float temp = 0;
        for (int channel = 0; channel < channelCount; ++channel) {
            float *out = (float *)outBufferListPtr->mBuffers[channel].mData + frameOffset;

            if (isStarted) {
                if (channel == 0) {
                    sp_bar_compute(sp, data->bar, &internalTrigger, &temp);
                }
                *out = temp;
            } else {
                *out = 0.0;
            }
        }
    }
}
