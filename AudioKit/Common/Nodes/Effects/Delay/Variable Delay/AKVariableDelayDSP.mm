// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "AKVariableDelayDSP.hpp"
#include "ParameterRamper.hpp"

extern "C" AKDSPRef createVariableDelayDSP() {
    return new AKVariableDelayDSP();
}

struct AKVariableDelayDSP::InternalData {
    sp_vdelay *vdelay0;
    sp_vdelay *vdelay1;
    ParameterRamper timeRamp;
    ParameterRamper feedbackRamp;
};

AKVariableDelayDSP::AKVariableDelayDSP() : data(new InternalData) {
    parameters[AKVariableDelayParameterTime] = &data->timeRamp;
    parameters[AKVariableDelayParameterFeedback] = &data->feedbackRamp;
    bCanProcessInPlace = false;
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

        float time = data->timeRamp.getAndStep();
        data->vdelay0->del = time;
        data->vdelay1->del = time;

        float feedback = data->feedbackRamp.getAndStep();
        data->vdelay0->feedback = feedback;
        data->vdelay1->feedback = feedback;

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
                sp_vdelay_compute(sp, data->vdelay0, in, out);
            } else {
                sp_vdelay_compute(sp, data->vdelay1, in, out);
            }
        }
    }
}
