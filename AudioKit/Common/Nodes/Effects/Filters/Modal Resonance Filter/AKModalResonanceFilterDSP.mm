//
//  AKModalResonanceFilterDSP.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#include "AKModalResonanceFilterDSP.hpp"
#import "AKLinearParameterRamp.hpp"

extern "C" AKDSPRef createModalResonanceFilterDSP(int channelCount, double sampleRate) {
    AKModalResonanceFilterDSP *dsp = new AKModalResonanceFilterDSP();
    dsp->init(channelCount, sampleRate);
    return dsp;
}

struct AKModalResonanceFilterDSP::InternalData {
    sp_mode *mode0;
    sp_mode *mode1;
    AKLinearParameterRamp frequencyRamp;
    AKLinearParameterRamp qualityFactorRamp;
};

AKModalResonanceFilterDSP::AKModalResonanceFilterDSP() : data(new InternalData) {
    data->frequencyRamp.setTarget(defaultFrequency, true);
    data->frequencyRamp.setDurationInSamples(defaultRampDurationSamples);
    data->qualityFactorRamp.setTarget(defaultQualityFactor, true);
    data->qualityFactorRamp.setDurationInSamples(defaultRampDurationSamples);
}

// Uses the ParameterAddress as a key
void AKModalResonanceFilterDSP::setParameter(AUParameterAddress address, AUValue value, bool immediate) {
    switch (address) {
        case AKModalResonanceFilterParameterFrequency:
            data->frequencyRamp.setTarget(clamp(value, frequencyLowerBound, frequencyUpperBound), immediate);
            break;
        case AKModalResonanceFilterParameterQualityFactor:
            data->qualityFactorRamp.setTarget(clamp(value, qualityFactorLowerBound, qualityFactorUpperBound), immediate);
            break;
        case AKModalResonanceFilterParameterRampDuration:
            data->frequencyRamp.setRampDuration(value, sampleRate);
            data->qualityFactorRamp.setRampDuration(value, sampleRate);
            break;
    }
}

// Uses the ParameterAddress as a key
float AKModalResonanceFilterDSP::getParameter(uint64_t address) {
    switch (address) {
        case AKModalResonanceFilterParameterFrequency:
            return data->frequencyRamp.getTarget();
        case AKModalResonanceFilterParameterQualityFactor:
            return data->qualityFactorRamp.getTarget();
        case AKModalResonanceFilterParameterRampDuration:
            return data->frequencyRamp.getRampDuration(sampleRate);
    }
    return 0;
}

void AKModalResonanceFilterDSP::init(int channelCount, double sampleRate) {
    AKSoundpipeDSPBase::init(channelCount, sampleRate);
    sp_mode_create(&data->mode0);
    sp_mode_init(sp, data->mode0);
    sp_mode_create(&data->mode1);
    sp_mode_init(sp, data->mode1);
    data->mode0->freq = defaultFrequency;
    data->mode1->freq = defaultFrequency;
    data->mode0->q = defaultQualityFactor;
    data->mode1->q = defaultQualityFactor;
}

void AKModalResonanceFilterDSP::deinit() {
    sp_mode_destroy(&data->mode0);
    sp_mode_destroy(&data->mode1);
}

void AKModalResonanceFilterDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);

        // do ramping every 8 samples
        if ((frameOffset & 0x7) == 0) {
            data->frequencyRamp.advanceTo(now + frameOffset);
            data->qualityFactorRamp.advanceTo(now + frameOffset);
        }

        data->mode0->freq = data->frequencyRamp.getValue();
        data->mode1->freq = data->frequencyRamp.getValue();
        data->mode0->q = data->qualityFactorRamp.getValue();
        data->mode1->q = data->qualityFactorRamp.getValue();

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
                sp_mode_compute(sp, data->mode0, in, out);
            } else {
                sp_mode_compute(sp, data->mode1, in, out);
            }
        }
    }
}
