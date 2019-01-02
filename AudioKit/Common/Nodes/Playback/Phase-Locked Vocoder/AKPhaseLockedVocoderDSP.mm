//
//  AKPhaseLockedVocoderDSP.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#include "AKPhaseLockedVocoderDSP.hpp"
#import "AKLinearParameterRamp.hpp"

extern "C" AKDSPRef createPhaseLockedVocoderDSP(int channelCount, double sampleRate) {
    AKPhaseLockedVocoderDSP *dsp = new AKPhaseLockedVocoderDSP();
    dsp->init(channelCount, sampleRate);
    return dsp;
}

struct AKPhaseLockedVocoderDSP::InternalData {
    sp_mincer *mincer;
    sp_ftbl *ftbl;
    UInt32 ftbl_size = 4096;

    AKLinearParameterRamp positionRamp;
    AKLinearParameterRamp amplitudeRamp;
    AKLinearParameterRamp pitchRatioRamp;
};

void AKPhaseLockedVocoderDSP::start() {
    AKSoundpipeDSPBase::start();
    sp_mincer_init(sp, data->mincer, data->ftbl, 2048);
    data->mincer->time = defaultPosition;
    data->mincer->amp = defaultAmplitude;
    data->mincer->pitch = defaultPitchRatio;
}

AKPhaseLockedVocoderDSP::AKPhaseLockedVocoderDSP() : data(new InternalData) {
}

// Uses the ParameterAddress as a key
void AKPhaseLockedVocoderDSP::setParameter(AUParameterAddress address, AUValue value, bool immediate) {
    switch (address) {
        case AKPhaseLockedVocoderParameterPosition:
            data->positionRamp.setTarget(clamp(value, positionLowerBound, positionUpperBound), immediate);
            break;
        case AKPhaseLockedVocoderParameterAmplitude:
            data->amplitudeRamp.setTarget(clamp(value, amplitudeLowerBound, amplitudeUpperBound), immediate);
            break;
        case AKPhaseLockedVocoderParameterPitchRatio:
            data->pitchRatioRamp.setTarget(clamp(value, pitchRatioLowerBound, pitchRatioUpperBound), immediate);
            break;
        case AKPhaseLockedVocoderParameterRampDuration:
            data->positionRamp.setRampDuration(value, sampleRate);
            data->amplitudeRamp.setRampDuration(value, sampleRate);
            data->pitchRatioRamp.setRampDuration(value, sampleRate);
            break;
    }
}

// Uses the ParameterAddress as a key
float AKPhaseLockedVocoderDSP::getParameter(uint64_t address) {
    switch (address) {
        case AKPhaseLockedVocoderParameterPosition:
            return data->positionRamp.getTarget();
        case AKPhaseLockedVocoderParameterAmplitude:
            return data->amplitudeRamp.getTarget();
        case AKPhaseLockedVocoderParameterPitchRatio:
            return data->pitchRatioRamp.getTarget();
        case AKPhaseLockedVocoderParameterRampDuration:
            return data->positionRamp.getRampDuration(sampleRate);
    }
    return 0;
}

void AKPhaseLockedVocoderDSP::init(int channelCount, double sampleRate) {
    AKSoundpipeDSPBase::init(channelCount, sampleRate);
    sp_mincer_create(&data->mincer);
}

void AKPhaseLockedVocoderDSP::setUpTable(float *table, UInt32 size) {
    data->ftbl_size = size;
    sp_ftbl_create(sp, &data->ftbl, data->ftbl_size);
    data->ftbl->tbl = table;
}

void AKPhaseLockedVocoderDSP::deinit() {
    sp_ftbl_destroy(&data->ftbl);
    sp_mincer_destroy(&data->mincer);
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
