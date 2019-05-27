//
//  AKZitaReverbDSP.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#include "AKZitaReverbDSP.hpp"
#import "AKLinearParameterRamp.hpp"

extern "C" AKDSPRef createZitaReverbDSP(int channelCount, double sampleRate) {
    AKZitaReverbDSP *dsp = new AKZitaReverbDSP();
    dsp->init(channelCount, sampleRate);
    return dsp;
}

struct AKZitaReverbDSP::InternalData {
    sp_zitarev *zitarev;
    AKLinearParameterRamp predelayRamp;
    AKLinearParameterRamp crossoverFrequencyRamp;
    AKLinearParameterRamp lowReleaseTimeRamp;
    AKLinearParameterRamp midReleaseTimeRamp;
    AKLinearParameterRamp dampingFrequencyRamp;
    AKLinearParameterRamp equalizerFrequency1Ramp;
    AKLinearParameterRamp equalizerLevel1Ramp;
    AKLinearParameterRamp equalizerFrequency2Ramp;
    AKLinearParameterRamp equalizerLevel2Ramp;
    AKLinearParameterRamp dryWetMixRamp;
};

AKZitaReverbDSP::AKZitaReverbDSP() : data(new InternalData) {
    data->predelayRamp.setTarget(defaultPredelay, true);
    data->predelayRamp.setDurationInSamples(defaultRampDurationSamples);
    data->crossoverFrequencyRamp.setTarget(defaultCrossoverFrequency, true);
    data->crossoverFrequencyRamp.setDurationInSamples(defaultRampDurationSamples);
    data->lowReleaseTimeRamp.setTarget(defaultLowReleaseTime, true);
    data->lowReleaseTimeRamp.setDurationInSamples(defaultRampDurationSamples);
    data->midReleaseTimeRamp.setTarget(defaultMidReleaseTime, true);
    data->midReleaseTimeRamp.setDurationInSamples(defaultRampDurationSamples);
    data->dampingFrequencyRamp.setTarget(defaultDampingFrequency, true);
    data->dampingFrequencyRamp.setDurationInSamples(defaultRampDurationSamples);
    data->equalizerFrequency1Ramp.setTarget(defaultEqualizerFrequency1, true);
    data->equalizerFrequency1Ramp.setDurationInSamples(defaultRampDurationSamples);
    data->equalizerLevel1Ramp.setTarget(defaultEqualizerLevel1, true);
    data->equalizerLevel1Ramp.setDurationInSamples(defaultRampDurationSamples);
    data->equalizerFrequency2Ramp.setTarget(defaultEqualizerFrequency2, true);
    data->equalizerFrequency2Ramp.setDurationInSamples(defaultRampDurationSamples);
    data->equalizerLevel2Ramp.setTarget(defaultEqualizerLevel2, true);
    data->equalizerLevel2Ramp.setDurationInSamples(defaultRampDurationSamples);
    data->dryWetMixRamp.setTarget(defaultDryWetMix, true);
    data->dryWetMixRamp.setDurationInSamples(defaultRampDurationSamples);
}

// Uses the ParameterAddress as a key
void AKZitaReverbDSP::setParameter(AUParameterAddress address, AUValue value, bool immediate) {
    switch (address) {
        case AKZitaReverbParameterPredelay:
            data->predelayRamp.setTarget(clamp(value, predelayLowerBound, predelayUpperBound), immediate);
            break;
        case AKZitaReverbParameterCrossoverFrequency:
            data->crossoverFrequencyRamp.setTarget(clamp(value, crossoverFrequencyLowerBound, crossoverFrequencyUpperBound), immediate);
            break;
        case AKZitaReverbParameterLowReleaseTime:
            data->lowReleaseTimeRamp.setTarget(clamp(value, lowReleaseTimeLowerBound, lowReleaseTimeUpperBound), immediate);
            break;
        case AKZitaReverbParameterMidReleaseTime:
            data->midReleaseTimeRamp.setTarget(clamp(value, midReleaseTimeLowerBound, midReleaseTimeUpperBound), immediate);
            break;
        case AKZitaReverbParameterDampingFrequency:
            data->dampingFrequencyRamp.setTarget(clamp(value, dampingFrequencyLowerBound, dampingFrequencyUpperBound), immediate);
            break;
        case AKZitaReverbParameterEqualizerFrequency1:
            data->equalizerFrequency1Ramp.setTarget(clamp(value, equalizerFrequency1LowerBound, equalizerFrequency1UpperBound), immediate);
            break;
        case AKZitaReverbParameterEqualizerLevel1:
            data->equalizerLevel1Ramp.setTarget(clamp(value, equalizerLevel1LowerBound, equalizerLevel1UpperBound), immediate);
            break;
        case AKZitaReverbParameterEqualizerFrequency2:
            data->equalizerFrequency2Ramp.setTarget(clamp(value, equalizerFrequency2LowerBound, equalizerFrequency2UpperBound), immediate);
            break;
        case AKZitaReverbParameterEqualizerLevel2:
            data->equalizerLevel2Ramp.setTarget(clamp(value, equalizerLevel2LowerBound, equalizerLevel2UpperBound), immediate);
            break;
        case AKZitaReverbParameterDryWetMix:
            data->dryWetMixRamp.setTarget(clamp(value, dryWetMixLowerBound, dryWetMixUpperBound), immediate);
            break;
        case AKZitaReverbParameterRampDuration:
            data->predelayRamp.setRampDuration(value, sampleRate);
            data->crossoverFrequencyRamp.setRampDuration(value, sampleRate);
            data->lowReleaseTimeRamp.setRampDuration(value, sampleRate);
            data->midReleaseTimeRamp.setRampDuration(value, sampleRate);
            data->dampingFrequencyRamp.setRampDuration(value, sampleRate);
            data->equalizerFrequency1Ramp.setRampDuration(value, sampleRate);
            data->equalizerLevel1Ramp.setRampDuration(value, sampleRate);
            data->equalizerFrequency2Ramp.setRampDuration(value, sampleRate);
            data->equalizerLevel2Ramp.setRampDuration(value, sampleRate);
            data->dryWetMixRamp.setRampDuration(value, sampleRate);
            break;
    }
}

// Uses the ParameterAddress as a key
float AKZitaReverbDSP::getParameter(uint64_t address) {
    switch (address) {
        case AKZitaReverbParameterPredelay:
            return data->predelayRamp.getTarget();
        case AKZitaReverbParameterCrossoverFrequency:
            return data->crossoverFrequencyRamp.getTarget();
        case AKZitaReverbParameterLowReleaseTime:
            return data->lowReleaseTimeRamp.getTarget();
        case AKZitaReverbParameterMidReleaseTime:
            return data->midReleaseTimeRamp.getTarget();
        case AKZitaReverbParameterDampingFrequency:
            return data->dampingFrequencyRamp.getTarget();
        case AKZitaReverbParameterEqualizerFrequency1:
            return data->equalizerFrequency1Ramp.getTarget();
        case AKZitaReverbParameterEqualizerLevel1:
            return data->equalizerLevel1Ramp.getTarget();
        case AKZitaReverbParameterEqualizerFrequency2:
            return data->equalizerFrequency2Ramp.getTarget();
        case AKZitaReverbParameterEqualizerLevel2:
            return data->equalizerLevel2Ramp.getTarget();
        case AKZitaReverbParameterDryWetMix:
            return data->dryWetMixRamp.getTarget();
        case AKZitaReverbParameterRampDuration:
            return data->predelayRamp.getRampDuration(sampleRate);
    }
    return 0;
}

void AKZitaReverbDSP::init(int channelCount, double sampleRate) {
    AKSoundpipeDSPBase::init(channelCount, sampleRate);
    sp_zitarev_create(&data->zitarev);
    sp_zitarev_init(sp, data->zitarev);
    *data->zitarev->in_delay = defaultPredelay;
    *data->zitarev->lf_x = defaultCrossoverFrequency;
    *data->zitarev->rt60_low = defaultLowReleaseTime;
    *data->zitarev->rt60_mid = defaultMidReleaseTime;
    *data->zitarev->hf_damping = defaultDampingFrequency;
    *data->zitarev->eq1_freq = defaultEqualizerFrequency1;
    *data->zitarev->eq1_level = defaultEqualizerLevel1;
    *data->zitarev->eq2_freq = defaultEqualizerFrequency2;
    *data->zitarev->eq2_level = defaultEqualizerLevel2;
    *data->zitarev->mix = defaultDryWetMix;
}

void AKZitaReverbDSP::deinit() {
    sp_zitarev_destroy(&data->zitarev);
}

void AKZitaReverbDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);

        // do ramping every 8 samples
        if ((frameOffset & 0x7) == 0) {
            data->predelayRamp.advanceTo(now + frameOffset);
            data->crossoverFrequencyRamp.advanceTo(now + frameOffset);
            data->lowReleaseTimeRamp.advanceTo(now + frameOffset);
            data->midReleaseTimeRamp.advanceTo(now + frameOffset);
            data->dampingFrequencyRamp.advanceTo(now + frameOffset);
            data->equalizerFrequency1Ramp.advanceTo(now + frameOffset);
            data->equalizerLevel1Ramp.advanceTo(now + frameOffset);
            data->equalizerFrequency2Ramp.advanceTo(now + frameOffset);
            data->equalizerLevel2Ramp.advanceTo(now + frameOffset);
            data->dryWetMixRamp.advanceTo(now + frameOffset);
        }

        *data->zitarev->in_delay = data->predelayRamp.getValue();
        *data->zitarev->lf_x = data->crossoverFrequencyRamp.getValue();
        *data->zitarev->rt60_low = data->lowReleaseTimeRamp.getValue();
        *data->zitarev->rt60_mid = data->midReleaseTimeRamp.getValue();
        *data->zitarev->hf_damping = data->dampingFrequencyRamp.getValue();
        *data->zitarev->eq1_freq = data->equalizerFrequency1Ramp.getValue();
        *data->zitarev->eq1_level = data->equalizerLevel1Ramp.getValue();
        *data->zitarev->eq2_freq = data->equalizerFrequency2Ramp.getValue();
        *data->zitarev->eq2_level = data->equalizerLevel2Ramp.getValue();
        *data->zitarev->mix = data->dryWetMixRamp.getValue();

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
            sp_zitarev_compute(sp, data->zitarev, tmpin[0], tmpin[1], tmpout[0], tmpout[1]);
        }
    }
}
