// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "AKToneComplementFilterDSP.hpp"
#include "ParameterRamper.hpp"

extern "C" AKDSPRef createToneComplementFilterDSP() {
    return new AKToneComplementFilterDSP();
}

struct AKToneComplementFilterDSP::InternalData {
    sp_atone *atone0;
    sp_atone *atone1;
    ParameterRamper halfPowerPointRamp;
};

AKToneComplementFilterDSP::AKToneComplementFilterDSP() : data(new InternalData) {
    parameters[AKToneComplementFilterParameterHalfPowerPoint] = &data->halfPowerPointRamp;
    bCanProcessInPlace = false;
}

void AKToneComplementFilterDSP::init(int channelCount, double sampleRate) {
    AKSoundpipeDSPBase::init(channelCount, sampleRate);
    sp_atone_create(&data->atone0);
    sp_atone_init(sp, data->atone0);
    sp_atone_create(&data->atone1);
    sp_atone_init(sp, data->atone1);
}

void AKToneComplementFilterDSP::deinit() {
    AKSoundpipeDSPBase::deinit();
    sp_atone_destroy(&data->atone0);
    sp_atone_destroy(&data->atone1);
}

void AKToneComplementFilterDSP::reset() {
    AKSoundpipeDSPBase::reset();
    if (!isInitialized) return;
    sp_atone_init(sp, data->atone0);
    sp_atone_init(sp, data->atone1);
}

void AKToneComplementFilterDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);

        float halfPowerPoint = data->halfPowerPointRamp.getAndStep();
        data->atone0->hp = halfPowerPoint;
        data->atone1->hp = halfPowerPoint;

        float *tmpin[2];
        float *tmpout[2];
        for (int channel = 0; channel < channelCount; ++channel) {
            float *in  = (float *)inputBufferLists[0]->mBuffers[channel].mData  + frameOffset;
            float *out = (float *)outputBufferLists[0]->mBuffers[channel].mData + frameOffset;
            if (channel < 2) {
                tmpin[channel] = in;
                tmpout[channel] = out;
            }
            if (!isStarted) {
                *out = *in;
                continue;
            }

            if (channel == 0) {
                sp_atone_compute(sp, data->atone0, in, out);
            } else {
                sp_atone_compute(sp, data->atone1, in, out);
            }
        }
    }
}
