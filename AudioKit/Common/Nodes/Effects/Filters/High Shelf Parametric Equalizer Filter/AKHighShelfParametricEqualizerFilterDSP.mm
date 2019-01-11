//
//  AKHighShelfParametricEqualizerFilterDSP.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#include "AKHighShelfParametricEqualizerFilterDSP.hpp"
#import "AKLinearParameterRamp.hpp"

extern "C" AKDSPRef createHighShelfParametricEqualizerFilterDSP(int channelCount, double sampleRate) {
    AKHighShelfParametricEqualizerFilterDSP *dsp = new AKHighShelfParametricEqualizerFilterDSP();
    dsp->init(channelCount, sampleRate);
    return dsp;
}

struct AKHighShelfParametricEqualizerFilterDSP::InternalData {
    sp_pareq *pareq0;
    sp_pareq *pareq1;
    AKLinearParameterRamp centerFrequencyRamp;
    AKLinearParameterRamp gainRamp;
    AKLinearParameterRamp qRamp;
};

AKHighShelfParametricEqualizerFilterDSP::AKHighShelfParametricEqualizerFilterDSP() : data(new InternalData) {
    data->centerFrequencyRamp.setTarget(defaultCenterFrequency, true);
    data->centerFrequencyRamp.setDurationInSamples(defaultRampDurationSamples);
    data->gainRamp.setTarget(defaultGain, true);
    data->gainRamp.setDurationInSamples(defaultRampDurationSamples);
    data->qRamp.setTarget(defaultQ, true);
    data->qRamp.setDurationInSamples(defaultRampDurationSamples);
}

// Uses the ParameterAddress as a key
void AKHighShelfParametricEqualizerFilterDSP::setParameter(AUParameterAddress address, AUValue value, bool immediate) {
    switch (address) {
        case AKHighShelfParametricEqualizerFilterParameterCenterFrequency:
            data->centerFrequencyRamp.setTarget(clamp(value, centerFrequencyLowerBound, centerFrequencyUpperBound), immediate);
            break;
        case AKHighShelfParametricEqualizerFilterParameterGain:
            data->gainRamp.setTarget(clamp(value, gainLowerBound, gainUpperBound), immediate);
            break;
        case AKHighShelfParametricEqualizerFilterParameterQ:
            data->qRamp.setTarget(clamp(value, qLowerBound, qUpperBound), immediate);
            break;
        case AKHighShelfParametricEqualizerFilterParameterRampDuration:
            data->centerFrequencyRamp.setRampDuration(value, sampleRate);
            data->gainRamp.setRampDuration(value, sampleRate);
            data->qRamp.setRampDuration(value, sampleRate);
            break;
    }
}

// Uses the ParameterAddress as a key
float AKHighShelfParametricEqualizerFilterDSP::getParameter(uint64_t address) {
    switch (address) {
        case AKHighShelfParametricEqualizerFilterParameterCenterFrequency:
            return data->centerFrequencyRamp.getTarget();
        case AKHighShelfParametricEqualizerFilterParameterGain:
            return data->gainRamp.getTarget();
        case AKHighShelfParametricEqualizerFilterParameterQ:
            return data->qRamp.getTarget();
        case AKHighShelfParametricEqualizerFilterParameterRampDuration:
            return data->centerFrequencyRamp.getRampDuration(sampleRate);
    }
    return 0;
}

void AKHighShelfParametricEqualizerFilterDSP::init(int channelCount, double sampleRate) {
    AKSoundpipeDSPBase::init(channelCount, sampleRate);
    sp_pareq_create(&data->pareq0);
    sp_pareq_init(sp, data->pareq0);
    sp_pareq_create(&data->pareq1);
    sp_pareq_init(sp, data->pareq1);
    data->pareq0->fc = defaultCenterFrequency;
    data->pareq1->fc = defaultCenterFrequency;
    data->pareq0->v = defaultGain;
    data->pareq1->v = defaultGain;
    data->pareq0->q = defaultQ;
    data->pareq1->q = defaultQ;
    data->pareq0->mode = 2;
    data->pareq1->mode = 2;
}

void AKHighShelfParametricEqualizerFilterDSP::deinit() {
    sp_pareq_destroy(&data->pareq0);
    sp_pareq_destroy(&data->pareq1);
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
