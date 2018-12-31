//
//  AKEqualizerFilterDSP.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#include "AKEqualizerFilterDSP.hpp"
#import "AKLinearParameterRamp.hpp"

extern "C" AKDSPRef createEqualizerFilterDSP(int nChannels, double sampleRate) {
    AKEqualizerFilterDSP *dsp = new AKEqualizerFilterDSP();
    dsp->init(nChannels, sampleRate);
    return dsp;
}

struct AKEqualizerFilterDSP::InternalData {
    sp_eqfil *eqfil0;
    sp_eqfil *eqfil1;
    AKLinearParameterRamp centerFrequencyRamp;
    AKLinearParameterRamp bandwidthRamp;
    AKLinearParameterRamp gainRamp;
};

AKEqualizerFilterDSP::AKEqualizerFilterDSP() : data(new InternalData) {
    data->centerFrequencyRamp.setTarget(defaultCenterFrequency, true);
    data->centerFrequencyRamp.setDurationInSamples(defaultRampDurationSamples);
    data->bandwidthRamp.setTarget(defaultBandwidth, true);
    data->bandwidthRamp.setDurationInSamples(defaultRampDurationSamples);
    data->gainRamp.setTarget(defaultGain, true);
    data->gainRamp.setDurationInSamples(defaultRampDurationSamples);
}

// Uses the ParameterAddress as a key
void AKEqualizerFilterDSP::setParameter(AUParameterAddress address, AUValue value, bool immediate) {
    switch (address) {
        case AKEqualizerFilterParameterCenterFrequency:
            data->centerFrequencyRamp.setTarget(clamp(value, centerFrequencyLowerBound, centerFrequencyUpperBound), immediate);
            break;
        case AKEqualizerFilterParameterBandwidth:
            data->bandwidthRamp.setTarget(clamp(value, bandwidthLowerBound, bandwidthUpperBound), immediate);
            break;
        case AKEqualizerFilterParameterGain:
            data->gainRamp.setTarget(clamp(value, gainLowerBound, gainUpperBound), immediate);
            break;
        case AKEqualizerFilterParameterRampDuration:
            data->centerFrequencyRamp.setRampDuration(value, _sampleRate);
            data->bandwidthRamp.setRampDuration(value, _sampleRate);
            data->gainRamp.setRampDuration(value, _sampleRate);
            break;
    }
}

// Uses the ParameterAddress as a key
float AKEqualizerFilterDSP::getParameter(uint64_t address) {
    switch (address) {
        case AKEqualizerFilterParameterCenterFrequency:
            return data->centerFrequencyRamp.getTarget();
        case AKEqualizerFilterParameterBandwidth:
            return data->bandwidthRamp.getTarget();
        case AKEqualizerFilterParameterGain:
            return data->gainRamp.getTarget();
        case AKEqualizerFilterParameterRampDuration:
            return data->centerFrequencyRamp.getRampDuration(_sampleRate);
    }
    return 0;
}

void AKEqualizerFilterDSP::init(int _channels, double _sampleRate) {
    AKSoundpipeDSPBase::init(_channels, _sampleRate);
    sp_eqfil_create(&data->eqfil0);
    sp_eqfil_init(_sp, data->eqfil0);
    sp_eqfil_create(&data->eqfil1);
    sp_eqfil_init(_sp, data->eqfil1);
    data->eqfil0->freq = defaultCenterFrequency;
    data->eqfil1->freq = defaultCenterFrequency;
    data->eqfil0->bw = defaultBandwidth;
    data->eqfil1->bw = defaultBandwidth;
    data->eqfil0->gain = defaultGain;
    data->eqfil1->gain = defaultGain;
}

void AKEqualizerFilterDSP::deinit() {
    sp_eqfil_destroy(&data->eqfil0);
    sp_eqfil_destroy(&data->eqfil1);
}

void AKEqualizerFilterDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);

        // do ramping every 8 samples
        if ((frameOffset & 0x7) == 0) {
            data->centerFrequencyRamp.advanceTo(_now + frameOffset);
            data->bandwidthRamp.advanceTo(_now + frameOffset);
            data->gainRamp.advanceTo(_now + frameOffset);
        }

        data->eqfil0->freq = data->centerFrequencyRamp.getValue();
        data->eqfil1->freq = data->centerFrequencyRamp.getValue();
        data->eqfil0->bw = data->bandwidthRamp.getValue();
        data->eqfil1->bw = data->bandwidthRamp.getValue();
        data->eqfil0->gain = data->gainRamp.getValue();
        data->eqfil1->gain = data->gainRamp.getValue();

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
                sp_eqfil_compute(_sp, data->eqfil0, in, out);
            } else {
                sp_eqfil_compute(_sp, data->eqfil1, in, out);
            }
        }
    }
}
