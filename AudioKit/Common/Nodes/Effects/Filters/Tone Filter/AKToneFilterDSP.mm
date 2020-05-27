// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "AKToneFilterDSP.hpp"
#include "ParameterRamper.hpp"

extern "C" AKDSPRef createToneFilterDSP() {
    return new AKToneFilterDSP();
}

struct AKToneFilterDSP::InternalData {
    sp_tone *tone0;
    sp_tone *tone1;
    ParameterRamper halfPowerPointRamp;
};

AKToneFilterDSP::AKToneFilterDSP() : data(new InternalData) {
    parameters[AKToneFilterParameterHalfPowerPoint] = &data->halfPowerPointRamp;
}

void AKToneFilterDSP::init(int channelCount, double sampleRate) {
    AKSoundpipeDSPBase::init(channelCount, sampleRate);
    sp_tone_create(&data->tone0);
    sp_tone_init(sp, data->tone0);
    sp_tone_create(&data->tone1);
    sp_tone_init(sp, data->tone1);
}

void AKToneFilterDSP::deinit() {
    AKSoundpipeDSPBase::deinit();
    sp_tone_destroy(&data->tone0);
    sp_tone_destroy(&data->tone1);
}

void AKToneFilterDSP::reset() {
    AKSoundpipeDSPBase::reset();
    if (!isInitialized) return;
    sp_tone_init(sp, data->tone0);
    sp_tone_init(sp, data->tone1);
}

void AKToneFilterDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);

        float halfPowerPoint = data->halfPowerPointRamp.getAndStep();
        data->tone0->hp = halfPowerPoint;
        data->tone1->hp = halfPowerPoint;

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
                sp_tone_compute(sp, data->tone0, in, out);
            } else {
                sp_tone_compute(sp, data->tone1, in, out);
            }
        }
    }
}
