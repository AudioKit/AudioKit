//
//  AKLowShelfParametricEqualizerFilterDSP.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#include "AKLowShelfParametricEqualizerFilterDSP.hpp"
#import "AKLinearParameterRamp.hpp"

extern "C" AKDSPRef createLowShelfParametricEqualizerFilterDSP(int nChannels, double sampleRate) {
    AKLowShelfParametricEqualizerFilterDSP *dsp = new AKLowShelfParametricEqualizerFilterDSP();
    dsp->init(nChannels, sampleRate);
    return dsp;
}

struct AKLowShelfParametricEqualizerFilterDSP::InternalData {
    sp_pareq *_pareq0;
    sp_pareq *_pareq1;
    AKLinearParameterRamp cornerFrequencyRamp;
    AKLinearParameterRamp gainRamp;
    AKLinearParameterRamp qRamp;
};

AKLowShelfParametricEqualizerFilterDSP::AKLowShelfParametricEqualizerFilterDSP() : data(new InternalData) {
    data->cornerFrequencyRamp.setTarget(defaultCornerFrequency, true);
    data->cornerFrequencyRamp.setDurationInSamples(defaultRampDurationSamples);
    data->gainRamp.setTarget(defaultGain, true);
    data->gainRamp.setDurationInSamples(defaultRampDurationSamples);
    data->qRamp.setTarget(defaultQ, true);
    data->qRamp.setDurationInSamples(defaultRampDurationSamples);
}

// Uses the ParameterAddress as a key
void AKLowShelfParametricEqualizerFilterDSP::setParameter(AUParameterAddress address, AUValue value, bool immediate) {
    switch (address) {
        case AKLowShelfParametricEqualizerFilterParameterCornerFrequency:
            data->cornerFrequencyRamp.setTarget(clamp(value, cornerFrequencyLowerBound, cornerFrequencyUpperBound), immediate);
            break;
        case AKLowShelfParametricEqualizerFilterParameterGain:
            data->gainRamp.setTarget(clamp(value, gainLowerBound, gainUpperBound), immediate);
            break;
        case AKLowShelfParametricEqualizerFilterParameterQ:
            data->qRamp.setTarget(clamp(value, qLowerBound, qUpperBound), immediate);
            break;
        case AKLowShelfParametricEqualizerFilterParameterRampDuration:
            data->cornerFrequencyRamp.setRampDuration(value, _sampleRate);
            data->gainRamp.setRampDuration(value, _sampleRate);
            data->qRamp.setRampDuration(value, _sampleRate);
            break;
    }
}

// Uses the ParameterAddress as a key
float AKLowShelfParametricEqualizerFilterDSP::getParameter(uint64_t address) {
    switch (address) {
        case AKLowShelfParametricEqualizerFilterParameterCornerFrequency:
            return data->cornerFrequencyRamp.getTarget();
        case AKLowShelfParametricEqualizerFilterParameterGain:
            return data->gainRamp.getTarget();
        case AKLowShelfParametricEqualizerFilterParameterQ:
            return data->qRamp.getTarget();
        case AKLowShelfParametricEqualizerFilterParameterRampDuration:
            return data->cornerFrequencyRamp.getRampDuration(_sampleRate);
    }
    return 0;
}

void AKLowShelfParametricEqualizerFilterDSP::init(int _channels, double _sampleRate) {
    AKSoundpipeDSPBase::init(_channels, _sampleRate);
    sp_pareq_create(&data->_pareq0);
    sp_pareq_init(_sp, data->_pareq0);
    sp_pareq_create(&data->_pareq1);
    sp_pareq_init(_sp, data->_pareq1);
    data->_pareq0->fc = defaultCornerFrequency;
    data->_pareq1->fc = defaultCornerFrequency;
    data->_pareq0->v = defaultGain;
    data->_pareq1->v = defaultGain;
    data->_pareq0->q = defaultQ;
    data->_pareq1->q = defaultQ;
    data->_pareq0->mode = 1;
    data->_pareq1->mode = 1;
}

void AKLowShelfParametricEqualizerFilterDSP::deinit() {
    sp_pareq_destroy(&data->_pareq0);
    sp_pareq_destroy(&data->_pareq1);
}

void AKLowShelfParametricEqualizerFilterDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);

        // do ramping every 8 samples
        if ((frameOffset & 0x7) == 0) {
            data->cornerFrequencyRamp.advanceTo(_now + frameOffset);
            data->gainRamp.advanceTo(_now + frameOffset);
            data->qRamp.advanceTo(_now + frameOffset);
        }

        data->_pareq0->fc = data->cornerFrequencyRamp.getValue();
        data->_pareq1->fc = data->cornerFrequencyRamp.getValue();
        data->_pareq0->v = data->gainRamp.getValue();
        data->_pareq1->v = data->gainRamp.getValue();
        data->_pareq0->q = data->qRamp.getValue();
        data->_pareq1->q = data->qRamp.getValue();

        float *tmpin[2];
        float *tmpout[2];
        for (int channel = 0; channel < _nChannels; ++channel) {
            float *in  = (float *)_inBufferListPtr->mBuffers[channel].mData  + frameOffset;
            float *out = (float *)_outBufferListPtr->mBuffers[channel].mData + frameOffset;
            if (channel < 2) {
                tmpin[channel] = in;
                tmpout[channel] = out;
            }
            if (!_playing) {
                *out = *in;
                continue;
            }

            if (channel == 0) {
                sp_pareq_compute(_sp, data->_pareq0, in, out);
            } else {
                sp_pareq_compute(_sp, data->_pareq1, in, out);
            }
        }
    }
}
