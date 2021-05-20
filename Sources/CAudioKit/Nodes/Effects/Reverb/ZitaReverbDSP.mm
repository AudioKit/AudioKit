// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "SoundpipeDSPBase.h"
#include "ParameterRamper.h"
#include "Soundpipe.h"

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

    void process(FrameRange range) override {
        for (int i : range) {

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

            float leftIn = inputSample(0, i);
            float rightIn = inputSample(1, i);

            float &leftOut = outputSample(0, i);
            float &rightOut = outputSample(1, i);
            
            sp_zitarev_compute(sp, zitarev, &leftIn, &rightIn, &leftOut, &rightOut);
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
