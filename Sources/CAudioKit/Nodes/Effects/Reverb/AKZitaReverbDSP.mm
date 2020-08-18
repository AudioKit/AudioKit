// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "AKSoundpipeDSPBase.hpp"
#include "ParameterRamper.hpp"
#include "soundpipe.h"

enum AKZitaReverbParameter : AUParameterAddress {
    AKZitaReverbParameterPredelay,
    AKZitaReverbParameterCrossoverFrequency,
    AKZitaReverbParameterLowReleaseTime,
    AKZitaReverbParameterMidReleaseTime,
    AKZitaReverbParameterDampingFrequency,
    AKZitaReverbParameterEqualizerFrequency1,
    AKZitaReverbParameterEqualizerLevel1,
    AKZitaReverbParameterEqualizerFrequency2,
    AKZitaReverbParameterEqualizerLevel2,
    AKZitaReverbParameterDryWetMix,
};

class AKZitaReverbDSP : public AKSoundpipeDSPBase {
private:
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

public:
    AKZitaReverbDSP() {
        parameters[AKZitaReverbParameterPredelay] = &predelayRamp;
        parameters[AKZitaReverbParameterCrossoverFrequency] = &crossoverFrequencyRamp;
        parameters[AKZitaReverbParameterLowReleaseTime] = &lowReleaseTimeRamp;
        parameters[AKZitaReverbParameterMidReleaseTime] = &midReleaseTimeRamp;
        parameters[AKZitaReverbParameterDampingFrequency] = &dampingFrequencyRamp;
        parameters[AKZitaReverbParameterEqualizerFrequency1] = &equalizerFrequency1Ramp;
        parameters[AKZitaReverbParameterEqualizerLevel1] = &equalizerLevel1Ramp;
        parameters[AKZitaReverbParameterEqualizerFrequency2] = &equalizerFrequency2Ramp;
        parameters[AKZitaReverbParameterEqualizerLevel2] = &equalizerLevel2Ramp;
        parameters[AKZitaReverbParameterDryWetMix] = &dryWetMixRamp;
    }

    void init(int channelCount, double sampleRate) override {
        AKSoundpipeDSPBase::init(channelCount, sampleRate);
        sp_zitarev_create(&zitarev);
        sp_zitarev_init(sp, zitarev);
    }

    void deinit() override {
        AKSoundpipeDSPBase::deinit();
        sp_zitarev_destroy(&zitarev);
    }

    void reset() override {
        AKSoundpipeDSPBase::reset();
        if (!isInitialized) return;
        sp_zitarev_init(sp, zitarev);
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {
        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            int frameOffset = int(frameIndex + bufferOffset);

            *zitarev->in_delay = predelayRamp.getAndStep();
            *zitarev->lf_x = crossoverFrequencyRamp.getAndStep();
            *zitarev->rt60_low = lowReleaseTimeRamp.getAndStep();
            *zitarev->rt60_mid = midReleaseTimeRamp.getAndStep();
            *zitarev->hf_damping = dampingFrequencyRamp.getAndStep();
            *zitarev->eq1_freq = equalizerFrequency1Ramp.getAndStep();
            *zitarev->eq1_level = equalizerLevel1Ramp.getAndStep();
            *zitarev->eq2_freq = equalizerFrequency2Ramp.getAndStep();
            *zitarev->eq2_level = equalizerLevel2Ramp.getAndStep();
            *zitarev->mix = dryWetMixRamp.getAndStep();

            float *tmpin[2];
            float *tmpout[2];
            for (int channel = 0; channel < channelCount; ++channel) {
                float *in  = (float *)inputBufferLists[0]->mBuffers[channel].mData  + frameOffset;
                float *out = (float *)outputBufferList->mBuffers[channel].mData + frameOffset;
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
                sp_zitarev_compute(sp, zitarev, tmpin[0], tmpin[1], tmpout[0], tmpout[1]);
            }
        }
    }
};

AK_REGISTER_DSP(AKZitaReverbDSP)
AK_REGISTER_PARAMETER(AKZitaReverbParameterPredelay)
AK_REGISTER_PARAMETER(AKZitaReverbParameterCrossoverFrequency)
AK_REGISTER_PARAMETER(AKZitaReverbParameterLowReleaseTime)
AK_REGISTER_PARAMETER(AKZitaReverbParameterMidReleaseTime)
AK_REGISTER_PARAMETER(AKZitaReverbParameterDampingFrequency)
AK_REGISTER_PARAMETER(AKZitaReverbParameterEqualizerFrequency1)
AK_REGISTER_PARAMETER(AKZitaReverbParameterEqualizerLevel1)
AK_REGISTER_PARAMETER(AKZitaReverbParameterEqualizerFrequency2)
AK_REGISTER_PARAMETER(AKZitaReverbParameterEqualizerLevel2)
AK_REGISTER_PARAMETER(AKZitaReverbParameterDryWetMix)
