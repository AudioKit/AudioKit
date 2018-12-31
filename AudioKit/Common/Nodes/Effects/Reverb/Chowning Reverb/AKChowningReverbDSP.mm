//
//  AKChowningReverbDSP.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#include "AKChowningReverbDSP.hpp"
#import "AKLinearParameterRamp.hpp"

extern "C" AKDSPRef createChowningReverbDSP(int channelCount, double sampleRate) {
    AKChowningReverbDSP *dsp = new AKChowningReverbDSP();
    dsp->init(channelCount, sampleRate);
    return dsp;
}

struct AKChowningReverbDSP::InternalData {
    sp_jcrev *jcrev0;
    sp_jcrev *jcrev1;
};

AKChowningReverbDSP::AKChowningReverbDSP() : data(new InternalData) {}

void AKChowningReverbDSP::init(int channelCount, double sampleRate) {
    AKSoundpipeDSPBase::init(channelCount, sampleRate);
    sp_jcrev_create(&data->jcrev0);
    sp_jcrev_init(sp, data->jcrev0);
    sp_jcrev_create(&data->jcrev1);
    sp_jcrev_init(sp, data->jcrev1);
}

void AKChowningReverbDSP::deinit() {
    sp_jcrev_destroy(&data->jcrev0);
    sp_jcrev_destroy(&data->jcrev1);
}

void AKChowningReverbDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);

        // do ramping every 8 samples
        if ((frameOffset & 0x7) == 0) {
        }


        float *tmpin[2];
        float *tmpout[2];
        for (int channel = 0; channel < channelCount; ++channel) {
            float *in  = (float *)inBufferListPtr->mBuffers[channel].mData  + frameOffset;
            float *out = (float *)outBufferListPtr->mBuffers[channel].mData + frameOffset;
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
