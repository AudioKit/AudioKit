// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "AKClipperDSP.hpp"
#include "ParameterRamper.hpp"

extern "C" AKDSPRef createClipperDSP() {
    return new AKClipperDSP();
}

struct AKClipperDSP::InternalData {
    sp_clip *clip0;
    sp_clip *clip1;
    ParameterRamper limitRamp;
};

AKClipperDSP::AKClipperDSP() : data(new InternalData) {
    parameters[AKClipperParameterLimit] = &data->limitRamp;
}

void AKClipperDSP::init(int channelCount, double sampleRate) {
    AKSoundpipeDSPBase::init(channelCount, sampleRate);
    sp_clip_create(&data->clip0);
    sp_clip_init(sp, data->clip0);
    sp_clip_create(&data->clip1);
    sp_clip_init(sp, data->clip1);
}

void AKClipperDSP::deinit() {
    AKSoundpipeDSPBase::deinit();
    sp_clip_destroy(&data->clip0);
    sp_clip_destroy(&data->clip1);
}

void AKClipperDSP::reset() {
    AKSoundpipeDSPBase::reset();
    if (!isInitialized) return;
    sp_clip_init(sp, data->clip0);
    sp_clip_init(sp, data->clip1);
}

void AKClipperDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);

        float limit = data->limitRamp.getAndStep();
        data->clip0->lim = limit;
        data->clip1->lim = limit;

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
                sp_clip_compute(sp, data->clip0, in, out);
            } else {
                sp_clip_compute(sp, data->clip1, in, out);
            }
        }
    }
}
