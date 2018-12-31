//
//  AKFlatFrequencyResponseReverbDSP.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#include "AKFlatFrequencyResponseReverbDSP.hpp"
#import "AKLinearParameterRamp.hpp"

extern "C" AKDSPRef createFlatFrequencyResponseReverbDSP(int channelCount, double sampleRate) {
    AKFlatFrequencyResponseReverbDSP *dsp = new AKFlatFrequencyResponseReverbDSP();
    dsp->init(channelCount, sampleRate);
    return dsp;
}

struct AKFlatFrequencyResponseReverbDSP::InternalData {
    sp_allpass *allpass0;
    sp_allpass *allpass1;
    float loopDuration = 0.1;
    AKLinearParameterRamp reverbDurationRamp;
};

void AKFlatFrequencyResponseReverbDSP::initializeConstant(float duration) {
    data->loopDuration = duration;
}


AKFlatFrequencyResponseReverbDSP::AKFlatFrequencyResponseReverbDSP() : data(new InternalData) {
    data->reverbDurationRamp.setTarget(defaultReverbDuration, true);
    data->reverbDurationRamp.setDurationInSamples(defaultRampDurationSamples);
}

// Uses the ParameterAddress as a key
void AKFlatFrequencyResponseReverbDSP::setParameter(AUParameterAddress address, AUValue value, bool immediate) {
    switch (address) {
        case AKFlatFrequencyResponseReverbParameterReverbDuration:
            data->reverbDurationRamp.setTarget(clamp(value, reverbDurationLowerBound, reverbDurationUpperBound), immediate);
            break;
        case AKFlatFrequencyResponseReverbParameterRampDuration:
            data->reverbDurationRamp.setRampDuration(value, sampleRate);
            break;
    }
}

// Uses the ParameterAddress as a key
float AKFlatFrequencyResponseReverbDSP::getParameter(uint64_t address) {
    switch (address) {
        case AKFlatFrequencyResponseReverbParameterReverbDuration:
            return data->reverbDurationRamp.getTarget();
        case AKFlatFrequencyResponseReverbParameterRampDuration:
            return data->reverbDurationRamp.getRampDuration(sampleRate);
    }
    return 0;
}

void AKFlatFrequencyResponseReverbDSP::init(int channelCount, double sampleRate) {
    AKSoundpipeDSPBase::init(channelCount, sampleRate);
    sp_allpass_create(&data->allpass0);
    sp_allpass_create(&data->allpass1);
    sp_allpass_init(sp, data->allpass0, data->loopDuration);
    sp_allpass_init(sp, data->allpass1, data->loopDuration);
    data->allpass0->revtime = defaultReverbDuration;
    data->allpass1->revtime = defaultReverbDuration;

}

void AKFlatFrequencyResponseReverbDSP::deinit() {
    sp_allpass_destroy(&data->allpass0);
    sp_allpass_destroy(&data->allpass1);
}

void AKFlatFrequencyResponseReverbDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);

        // do ramping every 8 samples
        if ((frameOffset & 0x7) == 0) {
            data->reverbDurationRamp.advanceTo(now + frameOffset);
        }

        data->allpass0->revtime = data->reverbDurationRamp.getValue();
        data->allpass1->revtime = data->reverbDurationRamp.getValue();

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
                sp_allpass_compute(sp, data->allpass0, in, out);
            } else {
                sp_allpass_compute(sp, data->allpass1, in, out);
            }
        }

    }
}
