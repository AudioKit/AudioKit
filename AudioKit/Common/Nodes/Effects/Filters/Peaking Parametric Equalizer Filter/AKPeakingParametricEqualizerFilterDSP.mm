//
//  AKPeakingParametricEqualizerFilterDSP.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#include "AKPeakingParametricEqualizerFilterDSP.hpp"
#import "AKLinearParameterRamp.hpp"

extern "C" AKDSPRef createPeakingParametricEqualizerFilterDSP(int nChannels, double sampleRate) {
    AKPeakingParametricEqualizerFilterDSP *dsp = new AKPeakingParametricEqualizerFilterDSP();
    dsp->init(nChannels, sampleRate);
    return dsp;
}

struct AKPeakingParametricEqualizerFilterDSP::InternalData {
    sp_pareq *_pareq0;
    sp_pareq *_pareq1;
    AKLinearParameterRamp centerFrequencyRamp;
    AKLinearParameterRamp gainRamp;
    AKLinearParameterRamp qRamp;
};

AKPeakingParametricEqualizerFilterDSP::AKPeakingParametricEqualizerFilterDSP() : data(new InternalData) {
    data->centerFrequencyRamp.setTarget(defaultCenterFrequency, true);
    data->centerFrequencyRamp.setDurationInSamples(defaultRampDurationSamples);
    data->gainRamp.setTarget(defaultGain, true);
    data->gainRamp.setDurationInSamples(defaultRampDurationSamples);
    data->qRamp.setTarget(defaultQ, true);
    data->qRamp.setDurationInSamples(defaultRampDurationSamples);
}

// Uses the ParameterAddress as a key
void AKPeakingParametricEqualizerFilterDSP::setParameter(AUParameterAddress address, AUValue value, bool immediate) {
    switch (address) {
        case AKPeakingParametricEqualizerFilterParameterCenterFrequency:
            data->centerFrequencyRamp.setTarget(clamp(value, centerFrequencyLowerBound, centerFrequencyUpperBound), immediate);
            break;
        case AKPeakingParametricEqualizerFilterParameterGain:
            data->gainRamp.setTarget(clamp(value, gainLowerBound, gainUpperBound), immediate);
            break;
        case AKPeakingParametricEqualizerFilterParameterQ:
            data->qRamp.setTarget(clamp(value, qLowerBound, qUpperBound), immediate);
            break;
        case AKPeakingParametricEqualizerFilterParameterRampDuration:
            data->centerFrequencyRamp.setRampDuration(value, _sampleRate);
            data->gainRamp.setRampDuration(value, _sampleRate);
            data->qRamp.setRampDuration(value, _sampleRate);
            break;
    }
}

// Uses the ParameterAddress as a key
float AKPeakingParametricEqualizerFilterDSP::getParameter(uint64_t address) {
    switch (address) {
        case AKPeakingParametricEqualizerFilterParameterCenterFrequency:
            return data->centerFrequencyRamp.getTarget();
        case AKPeakingParametricEqualizerFilterParameterGain:
            return data->gainRamp.getTarget();
        case AKPeakingParametricEqualizerFilterParameterQ:
            return data->qRamp.getTarget();
        case AKPeakingParametricEqualizerFilterParameterRampDuration:
            return data->centerFrequencyRamp.getRampDuration(_sampleRate);
    }
    return 0;
}

void AKPeakingParametricEqualizerFilterDSP::init(int _channels, double _sampleRate) {
    AKSoundpipeDSPBase::init(_channels, _sampleRate);
    sp_pareq_create(&data->_pareq0);
    sp_pareq_init(_sp, data->_pareq0);
    sp_pareq_create(&data->_pareq1);
    sp_pareq_init(_sp, data->_pareq1);
    data->_pareq0->fc = defaultCenterFrequency;
    data->_pareq1->fc = defaultCenterFrequency;
    data->_pareq0->v = defaultGain;
    data->_pareq1->v = defaultGain;
    data->_pareq0->q = defaultQ;
    data->_pareq1->q = defaultQ;
    data->_pareq0->mode = 0;
    data->_pareq1->mode = 0;
}

void AKPeakingParametricEqualizerFilterDSP::deinit() {
    sp_pareq_destroy(&data->_pareq0);
    sp_pareq_destroy(&data->_pareq1);
}

void AKPeakingParametricEqualizerFilterDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);

        // do ramping every 8 samples
        if ((frameOffset & 0x7) == 0) {
            data->centerFrequencyRamp.advanceTo(_now + frameOffset);
            data->gainRamp.advanceTo(_now + frameOffset);
            data->qRamp.advanceTo(_now + frameOffset);
        }

        data->_pareq0->fc = data->centerFrequencyRamp.getValue();
        data->_pareq1->fc = data->centerFrequencyRamp.getValue();
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
