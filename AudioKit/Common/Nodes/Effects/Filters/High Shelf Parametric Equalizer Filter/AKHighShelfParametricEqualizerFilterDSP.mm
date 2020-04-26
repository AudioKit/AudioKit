// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "AKHighShelfParametricEqualizerFilterDSP.hpp"
#include "AKLinearParameterRamp.hpp"

extern "C" AKDSPRef createHighShelfParametricEqualizerFilterDSP() {
    return new AKHighShelfParametricEqualizerFilterDSP();
}

struct AKHighShelfParametricEqualizerFilterDSP::InternalData {
    sp_pareq *pareq0;
    sp_pareq *pareq1;
    AKLinearParameterRamp centerFrequencyRamp;
    AKLinearParameterRamp gainRamp;
    AKLinearParameterRamp qRamp;
};

AKHighShelfParametricEqualizerFilterDSP::AKHighShelfParametricEqualizerFilterDSP() : data(new InternalData) {
    parameters[AKHighShelfParametricEqualizerFilterParameterCenterFrequency] = &data->centerFrequencyRamp;
    parameters[AKHighShelfParametricEqualizerFilterParameterGain] = &data->gainRamp;
    parameters[AKHighShelfParametricEqualizerFilterParameterQ] = &data->qRamp;
}

void AKHighShelfParametricEqualizerFilterDSP::init(int channelCount, double sampleRate) {
    AKSoundpipeDSPBase::init(channelCount, sampleRate);
    sp_pareq_create(&data->pareq0);
    sp_pareq_init(sp, data->pareq0);
    sp_pareq_create(&data->pareq1);
    sp_pareq_init(sp, data->pareq1);
    data->pareq0->mode = 2;
    data->pareq1->mode = 2;
}

void AKHighShelfParametricEqualizerFilterDSP::deinit() {
    AKSoundpipeDSPBase::deinit();
    sp_pareq_destroy(&data->pareq0);
    sp_pareq_destroy(&data->pareq1);
}

void AKHighShelfParametricEqualizerFilterDSP::reset() {
    AKSoundpipeDSPBase::reset();
    if (!isInitialized) return;
    sp_pareq_init(sp, data->pareq0);
    sp_pareq_init(sp, data->pareq1);
    data->pareq0->mode = 2;
    data->pareq1->mode = 2;
}

void AKHighShelfParametricEqualizerFilterDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);

        // do ramping every 8 samples
        if ((frameOffset & 0x7) == 0) {
            data->centerFrequencyRamp.advanceTo(now + frameOffset);
            data->gainRamp.advanceTo(now + frameOffset);
            data->qRamp.advanceTo(now + frameOffset);
        }

        data->pareq0->fc = data->centerFrequencyRamp.getValue();
        data->pareq1->fc = data->centerFrequencyRamp.getValue();
        data->pareq0->v = data->gainRamp.getValue();
        data->pareq1->v = data->gainRamp.getValue();
        data->pareq0->q = data->qRamp.getValue();
        data->pareq1->q = data->qRamp.getValue();

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
                sp_pareq_compute(sp, data->pareq0, in, out);
            } else {
                sp_pareq_compute(sp, data->pareq1, in, out);
            }
        }
    }
}
