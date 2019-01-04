//
//  AKStringResonatorDSP.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#include "AKStringResonatorDSP.hpp"
#import "AKLinearParameterRamp.hpp"

extern "C" AKDSPRef createStringResonatorDSP(int channelCount, double sampleRate) {
    AKStringResonatorDSP *dsp = new AKStringResonatorDSP();
    dsp->init(channelCount, sampleRate);
    return dsp;
}

struct AKStringResonatorDSP::InternalData {
    sp_streson *streson0;
    sp_streson *streson1;
    AKLinearParameterRamp fundamentalFrequencyRamp;
    AKLinearParameterRamp feedbackRamp;
};

AKStringResonatorDSP::AKStringResonatorDSP() : data(new InternalData) {
    data->fundamentalFrequencyRamp.setTarget(defaultFundamentalFrequency, true);
    data->fundamentalFrequencyRamp.setDurationInSamples(defaultRampDurationSamples);
    data->feedbackRamp.setTarget(defaultFeedback, true);
    data->feedbackRamp.setDurationInSamples(defaultRampDurationSamples);
}

// Uses the ParameterAddress as a key
void AKStringResonatorDSP::setParameter(AUParameterAddress address, AUValue value, bool immediate) {
    switch (address) {
        case AKStringResonatorParameterFundamentalFrequency:
            data->fundamentalFrequencyRamp.setTarget(clamp(value, fundamentalFrequencyLowerBound, fundamentalFrequencyUpperBound), immediate);
            break;
        case AKStringResonatorParameterFeedback:
            data->feedbackRamp.setTarget(clamp(value, feedbackLowerBound, feedbackUpperBound), immediate);
            break;
        case AKStringResonatorParameterRampDuration:
            data->fundamentalFrequencyRamp.setRampDuration(value, sampleRate);
            data->feedbackRamp.setRampDuration(value, sampleRate);
            break;
    }
}

// Uses the ParameterAddress as a key
float AKStringResonatorDSP::getParameter(uint64_t address) {
    switch (address) {
        case AKStringResonatorParameterFundamentalFrequency:
            return data->fundamentalFrequencyRamp.getTarget();
        case AKStringResonatorParameterFeedback:
            return data->feedbackRamp.getTarget();
        case AKStringResonatorParameterRampDuration:
            return data->fundamentalFrequencyRamp.getRampDuration(sampleRate);
    }
    return 0;
}

void AKStringResonatorDSP::init(int channelCount, double sampleRate) {
    AKSoundpipeDSPBase::init(channelCount, sampleRate);
    sp_streson_create(&data->streson0);
    sp_streson_init(sp, data->streson0);
    sp_streson_create(&data->streson1);
    sp_streson_init(sp, data->streson1);
    data->streson0->freq = defaultFundamentalFrequency;
    data->streson1->freq = defaultFundamentalFrequency;
    data->streson0->fdbgain = defaultFeedback;
    data->streson1->fdbgain = defaultFeedback;
}

void AKStringResonatorDSP::deinit() {
    sp_streson_destroy(&data->streson0);
    sp_streson_destroy(&data->streson1);
}

void AKStringResonatorDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);

        // do ramping every 8 samples
        if ((frameOffset & 0x7) == 0) {
            data->fundamentalFrequencyRamp.advanceTo(now + frameOffset);
            data->feedbackRamp.advanceTo(now + frameOffset);
        }

        data->streson0->freq = data->fundamentalFrequencyRamp.getValue();
        data->streson1->freq = data->fundamentalFrequencyRamp.getValue();
        data->streson0->fdbgain = data->feedbackRamp.getValue();
        data->streson1->fdbgain = data->feedbackRamp.getValue();

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
                sp_streson_compute(sp, data->streson0, in, out);
            } else {
                sp_streson_compute(sp, data->streson1, in, out);
            }
        }
    }
}
