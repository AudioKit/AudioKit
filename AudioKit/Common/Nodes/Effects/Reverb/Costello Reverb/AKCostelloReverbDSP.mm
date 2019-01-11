//
//  AKCostelloReverbDSP.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#include "AKCostelloReverbDSP.hpp"
#import "AKLinearParameterRamp.hpp"

extern "C" AKDSPRef createCostelloReverbDSP(int channelCount, double sampleRate) {
    AKCostelloReverbDSP *dsp = new AKCostelloReverbDSP();
    dsp->init(channelCount, sampleRate);
    return dsp;
}

struct AKCostelloReverbDSP::InternalData {
    sp_revsc *revsc;
    AKLinearParameterRamp feedbackRamp;
    AKLinearParameterRamp cutoffFrequencyRamp;
};

AKCostelloReverbDSP::AKCostelloReverbDSP() : data(new InternalData) {
    data->feedbackRamp.setTarget(defaultFeedback, true);
    data->feedbackRamp.setDurationInSamples(defaultRampDurationSamples);
    data->cutoffFrequencyRamp.setTarget(defaultCutoffFrequency, true);
    data->cutoffFrequencyRamp.setDurationInSamples(defaultRampDurationSamples);
}

// Uses the ParameterAddress as a key
void AKCostelloReverbDSP::setParameter(AUParameterAddress address, AUValue value, bool immediate) {
    switch (address) {
        case AKCostelloReverbParameterFeedback:
            data->feedbackRamp.setTarget(clamp(value, feedbackLowerBound, feedbackUpperBound), immediate);
            break;
        case AKCostelloReverbParameterCutoffFrequency:
            data->cutoffFrequencyRamp.setTarget(clamp(value, cutoffFrequencyLowerBound, cutoffFrequencyUpperBound), immediate);
            break;
        case AKCostelloReverbParameterRampDuration:
            data->feedbackRamp.setRampDuration(value, sampleRate);
            data->cutoffFrequencyRamp.setRampDuration(value, sampleRate);
            break;
    }
}

// Uses the ParameterAddress as a key
float AKCostelloReverbDSP::getParameter(uint64_t address) {
    switch (address) {
        case AKCostelloReverbParameterFeedback:
            return data->feedbackRamp.getTarget();
        case AKCostelloReverbParameterCutoffFrequency:
            return data->cutoffFrequencyRamp.getTarget();
        case AKCostelloReverbParameterRampDuration:
            return data->feedbackRamp.getRampDuration(sampleRate);
    }
    return 0;
}

void AKCostelloReverbDSP::init(int channelCount, double sampleRate) {
    AKSoundpipeDSPBase::init(channelCount, sampleRate);
    sp_revsc_create(&data->revsc);
    sp_revsc_init(sp, data->revsc);
    data->revsc->feedback = defaultFeedback;
    data->revsc->lpfreq = defaultCutoffFrequency;
}

void AKCostelloReverbDSP::deinit() {
    sp_revsc_destroy(&data->revsc);
}

void AKCostelloReverbDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);

        // do ramping every 8 samples
        if ((frameOffset & 0x7) == 0) {
            data->feedbackRamp.advanceTo(now + frameOffset);
            data->cutoffFrequencyRamp.advanceTo(now + frameOffset);
        }

        data->revsc->feedback = data->feedbackRamp.getValue();
        data->revsc->lpfreq = data->cutoffFrequencyRamp.getValue();

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
            }
        }
        if (isStarted) {
            sp_revsc_compute(sp, data->revsc, tmpin[0], tmpin[1], tmpout[0], tmpout[1]);
        }
    }
}
