//
//  AKKorgLowPassFilterDSP.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#include "AKKorgLowPassFilterDSP.hpp"
#import "AKLinearParameterRamp.hpp"

extern "C" AKDSPRef createKorgLowPassFilterDSP(int nChannels, double sampleRate) {
    AKKorgLowPassFilterDSP *dsp = new AKKorgLowPassFilterDSP();
    dsp->init(nChannels, sampleRate);
    return dsp;
}

struct AKKorgLowPassFilterDSP::_Internal {
    sp_wpkorg35 *_wpkorg350;
    sp_wpkorg35 *_wpkorg351;
    AKLinearParameterRamp cutoffFrequencyRamp;
    AKLinearParameterRamp resonanceRamp;
    AKLinearParameterRamp saturationRamp;
};

AKKorgLowPassFilterDSP::AKKorgLowPassFilterDSP() : data(new _Internal) {
    data->cutoffFrequencyRamp.setTarget(defaultCutoffFrequency, true);
    data->cutoffFrequencyRamp.setDurationInSamples(defaultRampDurationSamples);
    data->resonanceRamp.setTarget(defaultResonance, true);
    data->resonanceRamp.setDurationInSamples(defaultRampDurationSamples);
    data->saturationRamp.setTarget(defaultSaturation, true);
    data->saturationRamp.setDurationInSamples(defaultRampDurationSamples);
}

// Uses the ParameterAddress as a key
void AKKorgLowPassFilterDSP::setParameter(AUParameterAddress address, AUValue value, bool immediate) {
    switch (address) {
        case AKKorgLowPassFilterParameterCutoffFrequency:
            data->cutoffFrequencyRamp.setTarget(clamp(value, cutoffFrequencyLowerBound, cutoffFrequencyUpperBound), immediate);
            break;
        case AKKorgLowPassFilterParameterResonance:
            data->resonanceRamp.setTarget(clamp(value, resonanceLowerBound, resonanceUpperBound), immediate);
            break;
        case AKKorgLowPassFilterParameterSaturation:
            data->saturationRamp.setTarget(clamp(value, saturationLowerBound, saturationUpperBound), immediate);
            break;
        case AKKorgLowPassFilterParameterRampDuration:
            data->cutoffFrequencyRamp.setRampDuration(value, _sampleRate);
            data->resonanceRamp.setRampDuration(value, _sampleRate);
            data->saturationRamp.setRampDuration(value, _sampleRate);
            break;
    }
}

// Uses the ParameterAddress as a key
float AKKorgLowPassFilterDSP::getParameter(uint64_t address) {
    switch (address) {
        case AKKorgLowPassFilterParameterCutoffFrequency:
            return data->cutoffFrequencyRamp.getTarget();
        case AKKorgLowPassFilterParameterResonance:
            return data->resonanceRamp.getTarget();
        case AKKorgLowPassFilterParameterSaturation:
            return data->saturationRamp.getTarget();
        case AKKorgLowPassFilterParameterRampDuration:
            return data->cutoffFrequencyRamp.getRampDuration(_sampleRate);
    }
    return 0;
}

void AKKorgLowPassFilterDSP::init(int _channels, double _sampleRate) {
    AKSoundpipeDSPBase::init(_channels, _sampleRate);
    sp_wpkorg35_create(&data->_wpkorg350);
    sp_wpkorg35_init(_sp, data->_wpkorg350);
    sp_wpkorg35_create(&data->_wpkorg351);
    sp_wpkorg35_init(_sp, data->_wpkorg351);
    data->_wpkorg350->cutoff = defaultCutoffFrequency;
    data->_wpkorg351->cutoff = defaultCutoffFrequency;
    data->_wpkorg350->res = defaultResonance;
    data->_wpkorg351->res = defaultResonance;
    data->_wpkorg350->saturation = defaultSaturation;
    data->_wpkorg351->saturation = defaultSaturation;
}

void AKKorgLowPassFilterDSP::deinit() {
    sp_wpkorg35_destroy(&data->_wpkorg350);
    sp_wpkorg35_destroy(&data->_wpkorg351);
}

void AKKorgLowPassFilterDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);

        // do ramping every 8 samples
        if ((frameOffset & 0x7) == 0) {
            data->cutoffFrequencyRamp.advanceTo(_now + frameOffset);
            data->resonanceRamp.advanceTo(_now + frameOffset);
            data->saturationRamp.advanceTo(_now + frameOffset);
        }

        data->_wpkorg350->cutoff = data->cutoffFrequencyRamp.getValue() - 0.0001;
        data->_wpkorg351->cutoff = data->cutoffFrequencyRamp.getValue() - 0.0001;
        data->_wpkorg350->res = data->resonanceRamp.getValue();
        data->_wpkorg351->res = data->resonanceRamp.getValue();
        data->_wpkorg350->saturation = data->saturationRamp.getValue();
        data->_wpkorg351->saturation = data->saturationRamp.getValue();

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
                sp_wpkorg35_compute(_sp, data->_wpkorg350, in, out);
            } else {
                sp_wpkorg35_compute(_sp, data->_wpkorg351, in, out);
            }
        }
    }
}
