// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "AKMetalBarDSP.hpp"
#include "ParameterRamper.hpp"

extern "C" AKDSPRef createMetalBarDSP() {
    return new AKMetalBarDSP();
}

struct AKMetalBarDSP::InternalData {
    sp_bar *bar;
    ParameterRamper leftBoundaryConditionRamp;
    ParameterRamper rightBoundaryConditionRamp;
    ParameterRamper decayDurationRamp;
    ParameterRamper scanSpeedRamp;
    ParameterRamper positionRamp;
    ParameterRamper strikeVelocityRamp;
    ParameterRamper strikeWidthRamp;
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

        data->bar->bcL = data->leftBoundaryConditionRamp.getAndStep();
        data->bar->bcR = data->rightBoundaryConditionRamp.getAndStep();
        data->bar->T30 = data->decayDurationRamp.getAndStep();
        data->bar->scan = data->scanSpeedRamp.getAndStep();
        data->bar->pos = data->positionRamp.getAndStep();
        data->bar->vel = data->strikeVelocityRamp.getAndStep();
        data->bar->wid = data->strikeWidthRamp.getAndStep();

        float temp = 0;
        for (int channel = 0; channel < channelCount; ++channel) {
            float *out = (float *)outputBufferLists[0]->mBuffers[channel].mData + frameOffset;

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
