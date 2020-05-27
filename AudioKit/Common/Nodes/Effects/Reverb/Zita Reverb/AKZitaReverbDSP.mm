// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "AKZitaReverbDSP.hpp"
#include "ParameterRamper.hpp"

extern "C" AKDSPRef createZitaReverbDSP() {
    return new AKZitaReverbDSP();
}

struct AKZitaReverbDSP::InternalData {
    sp_zitarev *zitarev;
    ParameterRamper predelayRamp;
    ParameterRamper crossoverFrequencyRamp;
    ParameterRamper lowReleaseTimeRamp;
    ParameterRamper midReleaseTimeRamp;
    ParameterRamper dampingFrequencyRamp;
    ParameterRamper equalizerFrequency1Ramp;
    ParameterRamper equalizerLevel1Ramp;
    ParameterRamper equalizerFrequency2Ramp;
    ParameterRamper equalizerLevel2Ramp;
    ParameterRamper dryWetMixRamp;
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

        *data->zitarev->in_delay = data->predelayRamp.getAndStep();
        *data->zitarev->lf_x = data->crossoverFrequencyRamp.getAndStep();
        *data->zitarev->rt60_low = data->lowReleaseTimeRamp.getAndStep();
        *data->zitarev->rt60_mid = data->midReleaseTimeRamp.getAndStep();
        *data->zitarev->hf_damping = data->dampingFrequencyRamp.getAndStep();
        *data->zitarev->eq1_freq = data->equalizerFrequency1Ramp.getAndStep();
        *data->zitarev->eq1_level = data->equalizerLevel1Ramp.getAndStep();
        *data->zitarev->eq2_freq = data->equalizerFrequency2Ramp.getAndStep();
        *data->zitarev->eq2_level = data->equalizerLevel2Ramp.getAndStep();
        *data->zitarev->mix = data->dryWetMixRamp.getAndStep();

        float *tmpin[2];
        float *tmpout[2];
        for (int channel = 0; channel < channelCount; ++channel) {
            float *in  = (float *)inputBufferLists[0]->mBuffers[channel].mData  + frameOffset;
            float *out = (float *)outputBufferLists[0]->mBuffers[channel].mData + frameOffset;
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
