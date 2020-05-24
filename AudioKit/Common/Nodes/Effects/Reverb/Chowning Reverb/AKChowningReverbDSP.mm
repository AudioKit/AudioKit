// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "AKChowningReverbDSP.hpp"

extern "C" AKDSPRef createChowningReverbDSP() {
    return new AKChowningReverbDSP();
}

struct AKChowningReverbDSP::InternalData {
    sp_jcrev *jcrev0;
    sp_jcrev *jcrev1;
};

AKChowningReverbDSP::AKChowningReverbDSP() : data(new InternalData) {
}

void AKChowningReverbDSP::init(int channelCount, double sampleRate) {
    AKSoundpipeDSPBase::init(channelCount, sampleRate);
    sp_jcrev_create(&data->jcrev0);
    sp_jcrev_init(sp, data->jcrev0);
    sp_jcrev_create(&data->jcrev1);
    sp_jcrev_init(sp, data->jcrev1);
}

void AKChowningReverbDSP::deinit() {
    AKSoundpipeDSPBase::deinit();
    sp_jcrev_destroy(&data->jcrev0);
    sp_jcrev_destroy(&data->jcrev1);
}

void AKChowningReverbDSP::reset() {
    AKSoundpipeDSPBase::reset();
    if (!isInitialized) return;
    sp_jcrev_init(sp, data->jcrev0);
    sp_jcrev_init(sp, data->jcrev1);
}

void AKChowningReverbDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);

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
                sp_jcrev_compute(sp, data->jcrev0, in, out);
            } else {
                sp_jcrev_compute(sp, data->jcrev1, in, out);
            }
        }
    }
}
