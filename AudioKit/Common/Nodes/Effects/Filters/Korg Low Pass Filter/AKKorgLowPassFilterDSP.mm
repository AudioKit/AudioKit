//
//  AKKorgLowPassFilterDSP.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#include "AKKorgLowPassFilterDSP.hpp"
#import "AKLinearParameterRamp.hpp"

extern "C" AKDSPRef createKorgLowPassFilterDSP(int channelCount, double sampleRate) {
    AKKorgLowPassFilterDSP *dsp = new AKKorgLowPassFilterDSP();
    dsp->init(channelCount, sampleRate);
    return dsp;
}

struct AKKorgLowPassFilterDSP::InternalData {
    sp_wpkorg35 *wpkorg350;
    sp_wpkorg35 *wpkorg351;
    AKLinearParameterRamp cutoffFrequencyRamp;
    AKLinearParameterRamp resonanceRamp;
    AKLinearParameterRamp saturationRamp;
};

AKKorgLowPassFilterDSP::AKKorgLowPassFilterDSP() : data(new InternalData) {
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
            data->cutoffFrequencyRamp.setRampDuration(value, sampleRate);
            data->resonanceRamp.setRampDuration(value, sampleRate);
            data->saturationRamp.setRampDuration(value, sampleRate);
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
            return data->cutoffFrequencyRamp.getRampDuration(sampleRate);
    }
    return 0;
}

void AKKorgLowPassFilterDSP::init(int channelCount, double sampleRate) {
    AKSoundpipeDSPBase::init(channelCount, sampleRate);
    sp_wpkorg35_create(&data->wpkorg350);
    sp_wpkorg35_init(sp, data->wpkorg350);
    sp_wpkorg35_create(&data->wpkorg351);
    sp_wpkorg35_init(sp, data->wpkorg351);
    data->wpkorg350->cutoff = defaultCutoffFrequency;
    data->wpkorg351->cutoff = defaultCutoffFrequency;
    data->wpkorg350->res = defaultResonance;
    data->wpkorg351->res = defaultResonance;
    data->wpkorg350->saturation = defaultSaturation;
    data->wpkorg351->saturation = defaultSaturation;
}

void AKKorgLowPassFilterDSP::deinit() {
    sp_wpkorg35_destroy(&data->wpkorg350);
    sp_wpkorg35_destroy(&data->wpkorg351);
}

void AKKorgLowPassFilterDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);

        // do ramping every 8 samples
        if ((frameOffset & 0x7) == 0) {
            data->cutoffFrequencyRamp.advanceTo(now + frameOffset);
            data->resonanceRamp.advanceTo(now + frameOffset);
            data->saturationRamp.advanceTo(now + frameOffset);
        }

        data->wpkorg350->cutoff = data->cutoffFrequencyRamp.getValue() - 0.0001;
        data->wpkorg351->cutoff = data->cutoffFrequencyRamp.getValue() - 0.0001;
        data->wpkorg350->res = data->resonanceRamp.getValue();
        data->wpkorg351->res = data->resonanceRamp.getValue();
        data->wpkorg350->saturation = data->saturationRamp.getValue();
        data->wpkorg351->saturation = data->saturationRamp.getValue();

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
                sp_wpkorg35_compute(sp, data->wpkorg350, in, out);
            } else {
                sp_wpkorg35_compute(sp, data->wpkorg351, in, out);
            }
        }
    }
}
