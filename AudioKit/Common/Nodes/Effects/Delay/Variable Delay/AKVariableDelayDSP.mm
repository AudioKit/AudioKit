//
//  AKVariableDelayDSP.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2020 AudioKit. All rights reserved.
//

#include "AKVariableDelayDSP.hpp"
#include "AKLinearParameterRamp.hpp"

extern "C" AKDSPRef createVariableDelayDSP() {
    return new AKVariableDelayDSP();
}

struct AKVariableDelayDSP::InternalData {
    sp_vdelay *vdelay0;
    sp_vdelay *vdelay1;
    AKLinearParameterRamp timeRamp;
    AKLinearParameterRamp feedbackRamp;
};

AKVariableDelayDSP::AKVariableDelayDSP() : data(new InternalData) {
    parameters[AKVariableDelayParameterTime] = &data->timeRamp;
    parameters[AKVariableDelayParameterFeedback] = &data->feedbackRamp;
}

void AKVariableDelayDSP::init(int channelCount, double sampleRate) {
    AKSoundpipeDSPBase::init(channelCount, sampleRate);
    sp_vdelay_create(&data->vdelay0);
    sp_vdelay_init(sp, data->vdelay0, 10);
    sp_vdelay_create(&data->vdelay1);
    sp_vdelay_init(sp, data->vdelay1, 10);
}

void AKVariableDelayDSP::deinit() {
    AKSoundpipeDSPBase::deinit();
    sp_vdelay_destroy(&data->vdelay0);
    sp_vdelay_destroy(&data->vdelay1);
}

void AKVariableDelayDSP::reset() {
    AKSoundpipeDSPBase::reset();
    if (!isInitialized) return;
    sp_vdelay_init(sp, data->vdelay0, 10);
    sp_vdelay_init(sp, data->vdelay1, 10);
}

void AKVariableDelayDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);

        // do ramping every 8 samples
        if ((frameOffset & 0x7) == 0) {
            data->timeRamp.advanceTo(now + frameOffset);
            data->feedbackRamp.advanceTo(now + frameOffset);
        }

        data->vdelay0->del = data->timeRamp.getValue();
        data->vdelay1->del = data->timeRamp.getValue();
        data->vdelay0->feedback = data->feedbackRamp.getValue();
        data->vdelay1->feedback = data->feedbackRamp.getValue();

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
                sp_vdelay_compute(sp, data->vdelay0, in, out);
            } else {
                sp_vdelay_compute(sp, data->vdelay1, in, out);
            }
        }
    }
}
