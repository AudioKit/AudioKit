// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "AKStringResonatorDSP.hpp"
#include "AKLinearParameterRamp.hpp"

extern "C" AKDSPRef createStringResonatorDSP() {
    return new AKStringResonatorDSP();
}

struct AKStringResonatorDSP::InternalData {
    sp_streson *streson0;
    sp_streson *streson1;
    AKLinearParameterRamp fundamentalFrequencyRamp;
    AKLinearParameterRamp feedbackRamp;
};

AKStringResonatorDSP::AKStringResonatorDSP() : data(new InternalData) {
    parameters[AKStringResonatorParameterFundamentalFrequency] = &data->fundamentalFrequencyRamp;
    parameters[AKStringResonatorParameterFeedback] = &data->feedbackRamp;
}

void AKStringResonatorDSP::init(int channelCount, double sampleRate) {
    AKSoundpipeDSPBase::init(channelCount, sampleRate);
    sp_streson_create(&data->streson0);
    sp_streson_init(sp, data->streson0);
    sp_streson_create(&data->streson1);
    sp_streson_init(sp, data->streson1);
}

void AKStringResonatorDSP::deinit() {
    AKSoundpipeDSPBase::deinit();
    sp_streson_destroy(&data->streson0);
    sp_streson_destroy(&data->streson1);
}

void AKStringResonatorDSP::reset() {
    AKSoundpipeDSPBase::reset();
    if (!isInitialized) return;
    sp_streson_init(sp, data->streson0);
    sp_streson_init(sp, data->streson1);
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
                sp_streson_compute(sp, data->streson0, in, out);
            } else {
                sp_streson_compute(sp, data->streson1, in, out);
            }
        }
    }
}
