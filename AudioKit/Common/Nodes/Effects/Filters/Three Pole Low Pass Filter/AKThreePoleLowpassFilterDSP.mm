//
//  AKThreePoleLowpassFilterDSP.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#include "AKThreePoleLowpassFilterDSP.hpp"
#import "AKLinearParameterRamp.hpp"

extern "C" AKDSPRef createThreePoleLowpassFilterDSP(int channelCount, double sampleRate) {
    AKThreePoleLowpassFilterDSP *dsp = new AKThreePoleLowpassFilterDSP();
    dsp->init(channelCount, sampleRate);
    return dsp;
}

struct AKThreePoleLowpassFilterDSP::InternalData {
    sp_lpf18 *lpf180;
    sp_lpf18 *lpf181;
    AKLinearParameterRamp distortionRamp;
    AKLinearParameterRamp cutoffFrequencyRamp;
    AKLinearParameterRamp resonanceRamp;
};

AKThreePoleLowpassFilterDSP::AKThreePoleLowpassFilterDSP() : data(new InternalData) {
    data->distortionRamp.setTarget(defaultDistortion, true);
    data->distortionRamp.setDurationInSamples(defaultRampDurationSamples);
    data->cutoffFrequencyRamp.setTarget(defaultCutoffFrequency, true);
    data->cutoffFrequencyRamp.setDurationInSamples(defaultRampDurationSamples);
    data->resonanceRamp.setTarget(defaultResonance, true);
    data->resonanceRamp.setDurationInSamples(defaultRampDurationSamples);
}

// Uses the ParameterAddress as a key
void AKThreePoleLowpassFilterDSP::setParameter(AUParameterAddress address, AUValue value, bool immediate) {
    switch (address) {
        case AKThreePoleLowpassFilterParameterDistortion:
            data->distortionRamp.setTarget(clamp(value, distortionLowerBound, distortionUpperBound), immediate);
            break;
        case AKThreePoleLowpassFilterParameterCutoffFrequency:
            data->cutoffFrequencyRamp.setTarget(clamp(value, cutoffFrequencyLowerBound, cutoffFrequencyUpperBound), immediate);
            break;
        case AKThreePoleLowpassFilterParameterResonance:
            data->resonanceRamp.setTarget(clamp(value, resonanceLowerBound, resonanceUpperBound), immediate);
            break;
        case AKThreePoleLowpassFilterParameterRampDuration:
            data->distortionRamp.setRampDuration(value, sampleRate);
            data->cutoffFrequencyRamp.setRampDuration(value, sampleRate);
            data->resonanceRamp.setRampDuration(value, sampleRate);
            break;
    }
}

// Uses the ParameterAddress as a key
float AKThreePoleLowpassFilterDSP::getParameter(uint64_t address) {
    switch (address) {
        case AKThreePoleLowpassFilterParameterDistortion:
            return data->distortionRamp.getTarget();
        case AKThreePoleLowpassFilterParameterCutoffFrequency:
            return data->cutoffFrequencyRamp.getTarget();
        case AKThreePoleLowpassFilterParameterResonance:
            return data->resonanceRamp.getTarget();
        case AKThreePoleLowpassFilterParameterRampDuration:
            return data->distortionRamp.getRampDuration(sampleRate);
    }
    return 0;
}

void AKThreePoleLowpassFilterDSP::init(int channelCount, double sampleRate) {
    AKSoundpipeDSPBase::init(channelCount, sampleRate);
    sp_lpf18_create(&data->lpf180);
    sp_lpf18_init(sp, data->lpf180);
    sp_lpf18_create(&data->lpf181);
    sp_lpf18_init(sp, data->lpf181);
    data->lpf180->dist = defaultDistortion;
    data->lpf181->dist = defaultDistortion;
    data->lpf180->cutoff = defaultCutoffFrequency;
    data->lpf181->cutoff = defaultCutoffFrequency;
    data->lpf180->res = defaultResonance;
    data->lpf181->res = defaultResonance;
}

void AKThreePoleLowpassFilterDSP::deinit() {
    sp_lpf18_destroy(&data->lpf180);
    sp_lpf18_destroy(&data->lpf181);
}

void AKThreePoleLowpassFilterDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);

        // do ramping every 8 samples
        if ((frameOffset & 0x7) == 0) {
            data->distortionRamp.advanceTo(now + frameOffset);
            data->cutoffFrequencyRamp.advanceTo(now + frameOffset);
            data->resonanceRamp.advanceTo(now + frameOffset);
        }

        data->lpf180->dist = data->distortionRamp.getValue();
        data->lpf181->dist = data->distortionRamp.getValue();
        data->lpf180->cutoff = data->cutoffFrequencyRamp.getValue();
        data->lpf181->cutoff = data->cutoffFrequencyRamp.getValue();
        data->lpf180->res = data->resonanceRamp.getValue();
        data->lpf181->res = data->resonanceRamp.getValue();

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
                sp_lpf18_compute(sp, data->lpf180, in, out);
            } else {
                sp_lpf18_compute(sp, data->lpf181, in, out);
            }
        }
    }
}
