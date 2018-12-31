//
//  AKAutoWahDSP.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#include "AKAutoWahDSP.hpp"
#import "AKLinearParameterRamp.hpp"

extern "C" AKDSPRef createAutoWahDSP(int channelCount, double sampleRate) {
    AKAutoWahDSP *dsp = new AKAutoWahDSP();
    dsp->init(channelCount, sampleRate);
    return dsp;
}

struct AKAutoWahDSP::InternalData {
    sp_autowah *autowah0;
    sp_autowah *autowah1;
    AKLinearParameterRamp wahRamp;
    AKLinearParameterRamp mixRamp;
    AKLinearParameterRamp amplitudeRamp;
};

AKAutoWahDSP::AKAutoWahDSP() : data(new InternalData) {
    data->wahRamp.setTarget(defaultWah, true);
    data->wahRamp.setDurationInSamples(defaultRampDurationSamples);
    data->mixRamp.setTarget(defaultMix, true);
    data->mixRamp.setDurationInSamples(defaultRampDurationSamples);
    data->amplitudeRamp.setTarget(defaultAmplitude, true);
    data->amplitudeRamp.setDurationInSamples(defaultRampDurationSamples);
}

// Uses the ParameterAddress as a key
void AKAutoWahDSP::setParameter(AUParameterAddress address, AUValue value, bool immediate) {
    switch (address) {
        case AKAutoWahParameterWah:
            data->wahRamp.setTarget(clamp(value, wahLowerBound, wahUpperBound), immediate);
            break;
        case AKAutoWahParameterMix:
            data->mixRamp.setTarget(clamp(value, mixLowerBound, mixUpperBound), immediate);
            break;
        case AKAutoWahParameterAmplitude:
            data->amplitudeRamp.setTarget(clamp(value, amplitudeLowerBound, amplitudeUpperBound), immediate);
            break;
        case AKAutoWahParameterRampDuration:
            data->wahRamp.setRampDuration(value, sampleRate);
            data->mixRamp.setRampDuration(value, sampleRate);
            data->amplitudeRamp.setRampDuration(value, sampleRate);
            break;
    }
}

// Uses the ParameterAddress as a key
float AKAutoWahDSP::getParameter(uint64_t address) {
    switch (address) {
        case AKAutoWahParameterWah:
            return data->wahRamp.getTarget();
        case AKAutoWahParameterMix:
            return data->mixRamp.getTarget();
        case AKAutoWahParameterAmplitude:
            return data->amplitudeRamp.getTarget();
        case AKAutoWahParameterRampDuration:
            return data->wahRamp.getRampDuration(sampleRate);
    }
    return 0;
}

void AKAutoWahDSP::init(int channelCount, double sampleRate) {
    AKSoundpipeDSPBase::init(channelCount, sampleRate);
    sp_autowah_create(&data->autowah0);
    sp_autowah_init(sp, data->autowah0);
    sp_autowah_create(&data->autowah1);
    sp_autowah_init(sp, data->autowah1);
    *data->autowah0->wah = defaultWah;
    *data->autowah1->wah = defaultWah;
    *data->autowah0->mix = defaultMix;
    *data->autowah1->mix = defaultMix;
    *data->autowah0->level = defaultAmplitude;
    *data->autowah1->level = defaultAmplitude;
}

void AKAutoWahDSP::deinit() {
    sp_autowah_destroy(&data->autowah0);
    sp_autowah_destroy(&data->autowah1);
}

void AKAutoWahDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);

        // do ramping every 8 samples
        if ((frameOffset & 0x7) == 0) {
            data->wahRamp.advanceTo(now + frameOffset);
            data->mixRamp.advanceTo(now + frameOffset);
            data->amplitudeRamp.advanceTo(now + frameOffset);
        }

        *data->autowah0->wah = data->wahRamp.getValue();
        *data->autowah1->wah = data->wahRamp.getValue();
        *data->autowah0->mix = data->mixRamp.getValue() * 100;
        *data->autowah1->mix = data->mixRamp.getValue() * 100;
        *data->autowah0->level = data->amplitudeRamp.getValue();
        *data->autowah1->level = data->amplitudeRamp.getValue();

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
                sp_autowah_compute(sp, data->autowah0, in, out);
            } else {
                sp_autowah_compute(sp, data->autowah1, in, out);
            }
        }
    }
}
