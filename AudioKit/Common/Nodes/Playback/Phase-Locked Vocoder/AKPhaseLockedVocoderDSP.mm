// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "AKPhaseLockedVocoderDSP.hpp"
#include "ParameterRamper.hpp"
#include <vector>

extern "C" AKDSPRef createPhaseLockedVocoderDSP() {
    return new AKPhaseLockedVocoderDSP();
}

struct AKPhaseLockedVocoderDSP::InternalData {
    sp_mincer *mincer;
    sp_ftbl *ftbl;
    std::vector<float> wavetable;

    ParameterRamper positionRamp;
    ParameterRamper amplitudeRamp;
    ParameterRamper pitchRatioRamp;
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

        data->mincer->time = data->positionRamp.getAndStep();
        data->mincer->amp = data->amplitudeRamp.getAndStep();
        data->mincer->pitch = data->pitchRatioRamp.getAndStep();

        float *outL = (float *)outputBufferLists[0]->mBuffers[0].mData  + frameOffset;
        float *outR = (float *)outputBufferLists[0]->mBuffers[1].mData + frameOffset;
        if (isStarted) {
            sp_mincer_compute(sp, data->mincer, NULL, outL);
            *outR = *outL;
        } else {
            *outL = 0;
            *outR = 0;
        }
    }
}
