//
//  AKVariableDelayDSP.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#include "AKVariableDelayDSP.hpp"
#import "AKLinearParameterRamp.hpp"

extern "C" AKDSPRef createVariableDelayDSP(int channelCount, double sampleRate) {
    AKVariableDelayDSP *dsp = new AKVariableDelayDSP();
    dsp->init(channelCount, sampleRate);
    return dsp;
}

struct AKVariableDelayDSP::InternalData {
    sp_vdelay *vdelay0;
    sp_vdelay *vdelay1;
    AKLinearParameterRamp timeRamp;
    AKLinearParameterRamp feedbackRamp;
};

AKVariableDelayDSP::AKVariableDelayDSP() : data(new InternalData) {
    data->timeRamp.setTarget(defaultTime, true);
    data->timeRamp.setDurationInSamples(defaultRampDurationSamples);
    data->feedbackRamp.setTarget(defaultFeedback, true);
    data->feedbackRamp.setDurationInSamples(defaultRampDurationSamples);
}

// Uses the ParameterAddress as a key
void AKVariableDelayDSP::setParameter(AUParameterAddress address, AUValue value, bool immediate) {
    switch (address) {
        case AKVariableDelayParameterTime:
            data->timeRamp.setTarget(clamp(value, timeLowerBound, timeUpperBound), immediate);
            break;
        case AKVariableDelayParameterFeedback:
            data->feedbackRamp.setTarget(clamp(value, feedbackLowerBound, feedbackUpperBound), immediate);
            break;
        case AKVariableDelayParameterRampDuration:
            data->timeRamp.setRampDuration(value, sampleRate);
            data->feedbackRamp.setRampDuration(value, sampleRate);
            break;
    }
}

// Uses the ParameterAddress as a key
float AKVariableDelayDSP::getParameter(uint64_t address) {
    switch (address) {
        case AKVariableDelayParameterTime:
            return data->timeRamp.getTarget();
        case AKVariableDelayParameterFeedback:
            return data->feedbackRamp.getTarget();
        case AKVariableDelayParameterRampDuration:
            return data->timeRamp.getRampDuration(sampleRate);
    }
    return 0;
}

void AKVariableDelayDSP::init(int channelCount, double sampleRate) {
    AKSoundpipeDSPBase::init(channelCount, sampleRate);
    sp_vdelay_create(&data->vdelay0);
    sp_vdelay_init(sp, data->vdelay0, 10);
    sp_vdelay_create(&data->vdelay1);
    sp_vdelay_init(sp, data->vdelay1, 10);
    data->vdelay0->del = defaultTime;
    data->vdelay1->del = defaultTime;
    data->vdelay0->feedback = defaultFeedback;
    data->vdelay1->feedback = defaultFeedback;
}

void AKVariableDelayDSP::deinit() {
    sp_vdelay_destroy(&data->vdelay0);
    sp_vdelay_destroy(&data->vdelay1);
}

void AKVariableDelayDSP::clear() {
    sp_vdelay_reset(sp, data->vdelay0);
    sp_vdelay_reset(sp, data->vdelay1);
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
