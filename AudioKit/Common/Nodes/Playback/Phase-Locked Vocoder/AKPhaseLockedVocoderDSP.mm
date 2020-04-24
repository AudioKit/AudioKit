//
//  AKPhaseLockedVocoderDSP.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2020 AudioKit. All rights reserved.
//

#include "AKPhaseLockedVocoderDSP.hpp"
#include "AKLinearParameterRamp.hpp"
#include <vector>

extern "C" AKDSPRef createPhaseLockedVocoderDSP() {
    return new AKPhaseLockedVocoderDSP();
}

struct AKPhaseLockedVocoderDSP::InternalData {
    sp_mincer *mincer;
    sp_ftbl *ftbl;
    std::vector<float> wavetable;

    AKLinearParameterRamp positionRamp;
    AKLinearParameterRamp amplitudeRamp;
    AKLinearParameterRamp pitchRatioRamp;
};

AKPhaseLockedVocoderDSP::AKPhaseLockedVocoderDSP() : data(new InternalData) {
    parameters[AKPhaseLockedVocoderParameterPosition] = &data->positionRamp;
    parameters[AKPhaseLockedVocoderParameterAmplitude] = &data->amplitudeRamp;
    parameters[AKPhaseLockedVocoderParameterPitchRatio] = &data->pitchRatioRamp;
}

void AKPhaseLockedVocoderDSP::setWavetable(const float *table, size_t length, int index) {
    data->wavetable = std::vector<float>(table, table + length);
    if (!isInitialized) return;
    sp_ftbl_destroy(&data->ftbl);
    sp_ftbl_create(sp, &data->ftbl, data->wavetable.size());
    std::copy(data->wavetable.cbegin(), data->wavetable.cend(), data->ftbl->tbl);
    reset();
}

void AKPhaseLockedVocoderDSP::init(int channelCount, double sampleRate) {
    AKSoundpipeDSPBase::init(channelCount, sampleRate);
    sp_ftbl_create(sp, &data->ftbl, data->wavetable.size());
    std::copy(data->wavetable.cbegin(), data->wavetable.cend(), data->ftbl->tbl);
    sp_mincer_create(&data->mincer);
    sp_mincer_init(sp, data->mincer, data->ftbl, 2048);
}

void AKPhaseLockedVocoderDSP::deinit() {
    AKSoundpipeDSPBase::deinit();
    sp_ftbl_destroy(&data->ftbl);
    sp_mincer_destroy(&data->mincer);
}

void AKPhaseLockedVocoderDSP::reset() {
    AKSoundpipeDSPBase::reset();
    if (!isInitialized) return;
    sp_mincer_init(sp, data->mincer, data->ftbl, 2048);
}

void AKPhaseLockedVocoderDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);

        // do ramping every 8 samples
        if ((frameOffset & 0x7) == 0) {
            data->positionRamp.advanceTo(now + frameOffset);
            data->amplitudeRamp.advanceTo(now + frameOffset);
            data->pitchRatioRamp.advanceTo(now + frameOffset);
        }

        data->mincer->time = data->positionRamp.getValue();
        data->mincer->amp = data->amplitudeRamp.getValue();
        data->mincer->pitch = data->pitchRatioRamp.getValue();

        float *outL = (float *)outBufferListPtr->mBuffers[0].mData  + frameOffset;
        float *outR = (float *)outBufferListPtr->mBuffers[1].mData + frameOffset;
        if (isStarted) {
            sp_mincer_compute(sp, data->mincer, NULL, outL);
            *outR = *outL;
        } else {
            *outL = 0;
            *outR = 0;
        }
    }
}
