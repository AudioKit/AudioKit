// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "SoundpipeDSPBase.h"
#include "ParameterRamper.h"
#include "soundpipe.h"

enum ZitaReverbParameter : AUParameterAddress {
    ZitaReverbParameterPredelay,
    ZitaReverbParameterCrossoverFrequency,
    ZitaReverbParameterLowReleaseTime,
    ZitaReverbParameterMidReleaseTime,
    ZitaReverbParameterDampingFrequency,
    ZitaReverbParameterEqualizerFrequency1,
    ZitaReverbParameterEqualizerLevel1,
    ZitaReverbParameterEqualizerFrequency2,
    ZitaReverbParameterEqualizerLevel2,
    ZitaReverbParameterDryWetMix,
};

class ZitaReverbDSP : public SoundpipeDSPBase {
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
    ZitaReverbDSP() {
        parameters[ZitaReverbParameterPredelay] = &predelayRamp;
        parameters[ZitaReverbParameterCrossoverFrequency] = &crossoverFrequencyRamp;
        parameters[ZitaReverbParameterLowReleaseTime] = &lowReleaseTimeRamp;
        parameters[ZitaReverbParameterMidReleaseTime] = &midReleaseTimeRamp;
        parameters[ZitaReverbParameterDampingFrequency] = &dampingFrequencyRamp;
        parameters[ZitaReverbParameterEqualizerFrequency1] = &equalizerFrequency1Ramp;
        parameters[ZitaReverbParameterEqualizerLevel1] = &equalizerLevel1Ramp;
        parameters[ZitaReverbParameterEqualizerFrequency2] = &equalizerFrequency2Ramp;
        parameters[ZitaReverbParameterEqualizerLevel2] = &equalizerLevel2Ramp;
        parameters[ZitaReverbParameterDryWetMix] = &dryWetMixRamp;
    }

    void init(int channelCount, double sampleRate) override {
        SoundpipeDSPBase::init(channelCount, sampleRate);
        sp_zitarev_create(&zitarev);
        sp_zitarev_init(sp, zitarev);
    }

    void deinit() override {
        SoundpipeDSPBase::deinit();
        sp_zitarev_destroy(&zitarev);
    }

    void reset() override {
        SoundpipeDSPBase::reset();
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

AK_REGISTER_DSP(ZitaReverbDSP, "zita")
AK_REGISTER_PARAMETER(ZitaReverbParameterPredelay)
AK_REGISTER_PARAMETER(ZitaReverbParameterCrossoverFrequency)
AK_REGISTER_PARAMETER(ZitaReverbParameterLowReleaseTime)
AK_REGISTER_PARAMETER(ZitaReverbParameterMidReleaseTime)
AK_REGISTER_PARAMETER(ZitaReverbParameterDampingFrequency)
AK_REGISTER_PARAMETER(ZitaReverbParameterEqualizerFrequency1)
AK_REGISTER_PARAMETER(ZitaReverbParameterEqualizerLevel1)
AK_REGISTER_PARAMETER(ZitaReverbParameterEqualizerFrequency2)
AK_REGISTER_PARAMETER(ZitaReverbParameterEqualizerLevel2)
AK_REGISTER_PARAMETER(ZitaReverbParameterDryWetMix)
