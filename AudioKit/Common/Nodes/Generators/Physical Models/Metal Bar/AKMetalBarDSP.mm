//
//  AKMetalBarDSP.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2020 AudioKit. All rights reserved.
//

#include "AKMetalBarDSP.hpp"
#include "AKLinearParameterRamp.hpp"

extern "C" AKDSPRef createMetalBarDSP() {
    return new AKMetalBarDSP();
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
    parameters[AKMetalBarParameterLeftBoundaryCondition] = &data->leftBoundaryConditionRamp;
    parameters[AKMetalBarParameterRightBoundaryCondition] = &data->rightBoundaryConditionRamp;
    parameters[AKMetalBarParameterDecayDuration] = &data->decayDurationRamp;
    parameters[AKMetalBarParameterScanSpeed] = &data->scanSpeedRamp;
    parameters[AKMetalBarParameterPosition] = &data->positionRamp;
    parameters[AKMetalBarParameterStrikeVelocity] = &data->strikeVelocityRamp;
    parameters[AKMetalBarParameterStrikeWidth] = &data->strikeWidthRamp;
}

void AKMetalBarDSP::init(int channelCount, double sampleRate) {
    AKSoundpipeDSPBase::init(channelCount, sampleRate);
    sp_bar_create(&data->bar);
    sp_bar_init(sp, data->bar, 3, 0.0001);
}

void AKMetalBarDSP::deinit() {
    AKSoundpipeDSPBase::deinit();
    sp_bar_destroy(&data->bar);
}

void AKMetalBarDSP::reset() {
    AKSoundpipeDSPBase::reset();
    if (!isInitialized) return;
    sp_bar_init(sp, data->bar, 3, 0.0001);
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
                    sp_bar_compute(sp, data->bar, nil, &temp);
                }
                *out = temp;
            } else {
                *out = 0.0;
            }
        }
    }
}
