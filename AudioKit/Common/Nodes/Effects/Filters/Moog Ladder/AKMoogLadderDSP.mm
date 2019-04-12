//
//  AKMoogLadderDSP.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#include "AKMoogLadderDSP.hpp"
#import "AKLinearParameterRamp.hpp"

extern "C" AKDSPRef createMoogLadderDSP(int channelCount, double sampleRate) {
    AKMoogLadderDSP *dsp = new AKMoogLadderDSP();
    dsp->init(channelCount, sampleRate);
    return dsp;
}

struct AKMoogLadderDSP::InternalData {
    sp_moogladder *moogladder0;
    sp_moogladder *moogladder1;
    AKLinearParameterRamp cutoffFrequencyRamp;
    AKLinearParameterRamp resonanceRamp;
};

AKMoogLadderDSP::AKMoogLadderDSP() : data(new InternalData) {
    data->cutoffFrequencyRamp.setTarget(defaultCutoffFrequency, true);
    data->cutoffFrequencyRamp.setDurationInSamples(defaultRampDurationSamples);
    data->resonanceRamp.setTarget(defaultResonance, true);
    data->resonanceRamp.setDurationInSamples(defaultRampDurationSamples);
}

// Uses the ParameterAddress as a key
void AKMoogLadderDSP::setParameter(AUParameterAddress address, AUValue value, bool immediate) {
    switch (address) {
        case AKMoogLadderParameterCutoffFrequency:
            data->cutoffFrequencyRamp.setTarget(clamp(value, cutoffFrequencyLowerBound, cutoffFrequencyUpperBound), immediate);
            break;
        case AKMoogLadderParameterResonance:
            data->resonanceRamp.setTarget(clamp(value, resonanceLowerBound, resonanceUpperBound), immediate);
            break;
        case AKMoogLadderParameterRampDuration:
            data->cutoffFrequencyRamp.setRampDuration(value, sampleRate);
            data->resonanceRamp.setRampDuration(value, sampleRate);
            break;
    }
}

// Uses the ParameterAddress as a key
float AKMoogLadderDSP::getParameter(uint64_t address) {
    switch (address) {
        case AKMoogLadderParameterCutoffFrequency:
            return data->cutoffFrequencyRamp.getTarget();
        case AKMoogLadderParameterResonance:
            return data->resonanceRamp.getTarget();
        case AKMoogLadderParameterRampDuration:
            return data->cutoffFrequencyRamp.getRampDuration(sampleRate);
    }
    return 0;
}

void AKMoogLadderDSP::init(int channelCount, double sampleRate) {
    AKSoundpipeDSPBase::init(channelCount, sampleRate);
    sp_moogladder_create(&data->moogladder0);
    sp_moogladder_init(sp, data->moogladder0);
    sp_moogladder_create(&data->moogladder1);
    sp_moogladder_init(sp, data->moogladder1);
    data->moogladder0->freq = defaultCutoffFrequency;
    data->moogladder1->freq = defaultCutoffFrequency;
    data->moogladder0->res = defaultResonance;
    data->moogladder1->res = defaultResonance;
}

void AKMoogLadderDSP::deinit() {
    sp_moogladder_destroy(&data->moogladder0);
    sp_moogladder_destroy(&data->moogladder1);
}

void AKMoogLadderDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);

        // do ramping every 8 samples
        if ((frameOffset & 0x7) == 0) {
            data->cutoffFrequencyRamp.advanceTo(now + frameOffset);
            data->resonanceRamp.advanceTo(now + frameOffset);
        }

        data->moogladder0->freq = data->cutoffFrequencyRamp.getValue();
        data->moogladder1->freq = data->cutoffFrequencyRamp.getValue();
        data->moogladder0->res = data->resonanceRamp.getValue();
        data->moogladder1->res = data->resonanceRamp.getValue();

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
                sp_moogladder_compute(sp, data->moogladder0, in, out);
            } else {
                sp_moogladder_compute(sp, data->moogladder1, in, out);
            }
        }
    }
}
