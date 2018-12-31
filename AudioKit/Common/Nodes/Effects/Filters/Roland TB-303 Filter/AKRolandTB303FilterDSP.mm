//
//  AKRolandTB303FilterDSP.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#include "AKRolandTB303FilterDSP.hpp"
#import "AKLinearParameterRamp.hpp"

extern "C" AKDSPRef createRolandTB303FilterDSP(int channelCount, double sampleRate) {
    AKRolandTB303FilterDSP *dsp = new AKRolandTB303FilterDSP();
    dsp->init(channelCount, sampleRate);
    return dsp;
}

struct AKRolandTB303FilterDSP::InternalData {
    sp_tbvcf *tbvcf0;
    sp_tbvcf *tbvcf1;
    AKLinearParameterRamp cutoffFrequencyRamp;
    AKLinearParameterRamp resonanceRamp;
    AKLinearParameterRamp distortionRamp;
    AKLinearParameterRamp resonanceAsymmetryRamp;
};

AKRolandTB303FilterDSP::AKRolandTB303FilterDSP() : data(new InternalData) {
    data->cutoffFrequencyRamp.setTarget(defaultCutoffFrequency, true);
    data->cutoffFrequencyRamp.setDurationInSamples(defaultRampDurationSamples);
    data->resonanceRamp.setTarget(defaultResonance, true);
    data->resonanceRamp.setDurationInSamples(defaultRampDurationSamples);
    data->distortionRamp.setTarget(defaultDistortion, true);
    data->distortionRamp.setDurationInSamples(defaultRampDurationSamples);
    data->resonanceAsymmetryRamp.setTarget(defaultResonanceAsymmetry, true);
    data->resonanceAsymmetryRamp.setDurationInSamples(defaultRampDurationSamples);
}

// Uses the ParameterAddress as a key
void AKRolandTB303FilterDSP::setParameter(AUParameterAddress address, AUValue value, bool immediate) {
    switch (address) {
        case AKRolandTB303FilterParameterCutoffFrequency:
            data->cutoffFrequencyRamp.setTarget(clamp(value, cutoffFrequencyLowerBound, cutoffFrequencyUpperBound), immediate);
            break;
        case AKRolandTB303FilterParameterResonance:
            data->resonanceRamp.setTarget(clamp(value, resonanceLowerBound, resonanceUpperBound), immediate);
            break;
        case AKRolandTB303FilterParameterDistortion:
            data->distortionRamp.setTarget(clamp(value, distortionLowerBound, distortionUpperBound), immediate);
            break;
        case AKRolandTB303FilterParameterResonanceAsymmetry:
            data->resonanceAsymmetryRamp.setTarget(clamp(value, resonanceAsymmetryLowerBound, resonanceAsymmetryUpperBound), immediate);
            break;
        case AKRolandTB303FilterParameterRampDuration:
            data->cutoffFrequencyRamp.setRampDuration(value, sampleRate);
            data->resonanceRamp.setRampDuration(value, sampleRate);
            data->distortionRamp.setRampDuration(value, sampleRate);
            data->resonanceAsymmetryRamp.setRampDuration(value, sampleRate);
            break;
    }
}

// Uses the ParameterAddress as a key
float AKRolandTB303FilterDSP::getParameter(uint64_t address) {
    switch (address) {
        case AKRolandTB303FilterParameterCutoffFrequency:
            return data->cutoffFrequencyRamp.getTarget();
        case AKRolandTB303FilterParameterResonance:
            return data->resonanceRamp.getTarget();
        case AKRolandTB303FilterParameterDistortion:
            return data->distortionRamp.getTarget();
        case AKRolandTB303FilterParameterResonanceAsymmetry:
            return data->resonanceAsymmetryRamp.getTarget();
        case AKRolandTB303FilterParameterRampDuration:
            return data->cutoffFrequencyRamp.getRampDuration(sampleRate);
    }
    return 0;
}

void AKRolandTB303FilterDSP::init(int channelCount, double sampleRate) {
    AKSoundpipeDSPBase::init(channelCount, sampleRate);
    sp_tbvcf_create(&data->tbvcf0);
    sp_tbvcf_init(sp, data->tbvcf0);
    sp_tbvcf_create(&data->tbvcf1);
    sp_tbvcf_init(sp, data->tbvcf1);
    data->tbvcf0->fco = defaultCutoffFrequency;
    data->tbvcf1->fco = defaultCutoffFrequency;
    data->tbvcf0->res = defaultResonance;
    data->tbvcf1->res = defaultResonance;
    data->tbvcf0->dist = defaultDistortion;
    data->tbvcf1->dist = defaultDistortion;
    data->tbvcf0->asym = defaultResonanceAsymmetry;
    data->tbvcf1->asym = defaultResonanceAsymmetry;
}

void AKRolandTB303FilterDSP::deinit() {
    sp_tbvcf_destroy(&data->tbvcf0);
    sp_tbvcf_destroy(&data->tbvcf1);
}

void AKRolandTB303FilterDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);

        // do ramping every 8 samples
        if ((frameOffset & 0x7) == 0) {
            data->cutoffFrequencyRamp.advanceTo(now + frameOffset);
            data->resonanceRamp.advanceTo(now + frameOffset);
            data->distortionRamp.advanceTo(now + frameOffset);
            data->resonanceAsymmetryRamp.advanceTo(now + frameOffset);
        }

        data->tbvcf0->fco = data->cutoffFrequencyRamp.getValue();
        data->tbvcf1->fco = data->cutoffFrequencyRamp.getValue();
        data->tbvcf0->res = data->resonanceRamp.getValue();
        data->tbvcf1->res = data->resonanceRamp.getValue();
        data->tbvcf0->dist = data->distortionRamp.getValue();
        data->tbvcf1->dist = data->distortionRamp.getValue();
        data->tbvcf0->asym = data->resonanceAsymmetryRamp.getValue();
        data->tbvcf1->asym = data->resonanceAsymmetryRamp.getValue();

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
                sp_tbvcf_compute(sp, data->tbvcf0, in, out);
            } else {
                sp_tbvcf_compute(sp, data->tbvcf1, in, out);
            }
        }
    }
}
