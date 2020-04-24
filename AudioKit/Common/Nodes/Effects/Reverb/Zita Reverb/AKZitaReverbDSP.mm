//
//  AKZitaReverbDSP.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2020 AudioKit. All rights reserved.
//

#include "AKZitaReverbDSP.hpp"
#include "AKLinearParameterRamp.hpp"

extern "C" AKDSPRef createZitaReverbDSP() {
    return new AKZitaReverbDSP();
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
    parameters[AKZitaReverbParameterPredelay] = &data->predelayRamp;
    parameters[AKZitaReverbParameterCrossoverFrequency] = &data->crossoverFrequencyRamp;
    parameters[AKZitaReverbParameterLowReleaseTime] = &data->lowReleaseTimeRamp;
    parameters[AKZitaReverbParameterMidReleaseTime] = &data->midReleaseTimeRamp;
    parameters[AKZitaReverbParameterDampingFrequency] = &data->dampingFrequencyRamp;
    parameters[AKZitaReverbParameterEqualizerFrequency1] = &data->equalizerFrequency1Ramp;
    parameters[AKZitaReverbParameterEqualizerLevel1] = &data->equalizerLevel1Ramp;
    parameters[AKZitaReverbParameterEqualizerFrequency2] = &data->equalizerFrequency2Ramp;
    parameters[AKZitaReverbParameterEqualizerLevel2] = &data->equalizerLevel2Ramp;
    parameters[AKZitaReverbParameterDryWetMix] = &data->dryWetMixRamp;
}

void AKZitaReverbDSP::init(int channelCount, double sampleRate) {
    AKSoundpipeDSPBase::init(channelCount, sampleRate);
    sp_zitarev_create(&data->zitarev);
    sp_zitarev_init(sp, data->zitarev);
}

void AKZitaReverbDSP::deinit() {
    AKSoundpipeDSPBase::deinit();
    sp_zitarev_destroy(&data->zitarev);
}

void AKZitaReverbDSP::reset() {
    AKSoundpipeDSPBase::reset();
    if (!isInitialized) return;
    sp_zitarev_init(sp, data->zitarev);
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
                continue;
            }
            
        }
        if (isStarted) {
            sp_zitarev_compute(sp, data->zitarev, tmpin[0], tmpin[1], tmpout[0], tmpout[1]);
        }
    }
}
