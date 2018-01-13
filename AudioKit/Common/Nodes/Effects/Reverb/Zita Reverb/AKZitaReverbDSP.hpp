//
//  AKZitaReverbDSP.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once

#import <Foundation/Foundation.h>

typedef NS_ENUM(int64_t, AKZitaReverbParameter) {
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
    AKZitaReverbParameterRampTime
};

#import "AKLinearParameterRamp.hpp"  // have to put this here to get it included in umbrella header

#ifndef __cplusplus

void* createZitaReverbDSP(int nChannels, double sampleRate);

#else

#import "AKSoundpipeDSPBase.hpp"

class AKZitaReverbDSP : public AKSoundpipeDSPBase {

    sp_zitarev *_zitarev;


private:
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
   
public:
    AKZitaReverbDSP() {
        predelayRamp.setTarget(60.0, true);
        predelayRamp.setDurationInSamples(10000);
        crossoverFrequencyRamp.setTarget(200.0, true);
        crossoverFrequencyRamp.setDurationInSamples(10000);
        lowReleaseTimeRamp.setTarget(3.0, true);
        lowReleaseTimeRamp.setDurationInSamples(10000);
        midReleaseTimeRamp.setTarget(2.0, true);
        midReleaseTimeRamp.setDurationInSamples(10000);
        dampingFrequencyRamp.setTarget(6000.0, true);
        dampingFrequencyRamp.setDurationInSamples(10000);
        equalizerFrequency1Ramp.setTarget(315.0, true);
        equalizerFrequency1Ramp.setDurationInSamples(10000);
        equalizerLevel1Ramp.setTarget(0.0, true);
        equalizerLevel1Ramp.setDurationInSamples(10000);
        equalizerFrequency2Ramp.setTarget(1500.0, true);
        equalizerFrequency2Ramp.setDurationInSamples(10000);
        equalizerLevel2Ramp.setTarget(0.0, true);
        equalizerLevel2Ramp.setDurationInSamples(10000);
        dryWetMixRamp.setTarget(1.0, true);
        dryWetMixRamp.setDurationInSamples(10000);
    }

    /** Uses the ParameterAddress as a key */
    void setParameter(uint64_t address, float value, bool immediate) override {
        switch (address) {
            case AKZitaReverbParameterPredelay:
                predelayRamp.setTarget(value, immediate);
                break;
            case AKZitaReverbParameterCrossoverFrequency:
                crossoverFrequencyRamp.setTarget(value, immediate);
                break;
            case AKZitaReverbParameterLowReleaseTime:
                lowReleaseTimeRamp.setTarget(value, immediate);
                break;
            case AKZitaReverbParameterMidReleaseTime:
                midReleaseTimeRamp.setTarget(value, immediate);
                break;
            case AKZitaReverbParameterDampingFrequency:
                dampingFrequencyRamp.setTarget(value, immediate);
                break;
            case AKZitaReverbParameterEqualizerFrequency1:
                equalizerFrequency1Ramp.setTarget(value, immediate);
                break;
            case AKZitaReverbParameterEqualizerLevel1:
                equalizerLevel1Ramp.setTarget(value, immediate);
                break;
            case AKZitaReverbParameterEqualizerFrequency2:
                equalizerFrequency2Ramp.setTarget(value, immediate);
                break;
            case AKZitaReverbParameterEqualizerLevel2:
                equalizerLevel2Ramp.setTarget(value, immediate);
                break;
            case AKZitaReverbParameterDryWetMix:
                dryWetMixRamp.setTarget(value, immediate);
                break;
            case AKZitaReverbParameterRampTime:
                predelayRamp.setRampTime(value, _sampleRate);
                crossoverFrequencyRamp.setRampTime(value, _sampleRate);
                lowReleaseTimeRamp.setRampTime(value, _sampleRate);
                midReleaseTimeRamp.setRampTime(value, _sampleRate);
                dampingFrequencyRamp.setRampTime(value, _sampleRate);
                equalizerFrequency1Ramp.setRampTime(value, _sampleRate);
                equalizerLevel1Ramp.setRampTime(value, _sampleRate);
                equalizerFrequency2Ramp.setRampTime(value, _sampleRate);
                equalizerLevel2Ramp.setRampTime(value, _sampleRate);
                dryWetMixRamp.setRampTime(value, _sampleRate);
                break;
        }
    }

    /** Uses the ParameterAddress as a key */
    float getParameter(uint64_t address) override {
        switch (address) {
            case AKZitaReverbParameterPredelay:
                return predelayRamp.getTarget();
            case AKZitaReverbParameterCrossoverFrequency:
                return crossoverFrequencyRamp.getTarget();
            case AKZitaReverbParameterLowReleaseTime:
                return lowReleaseTimeRamp.getTarget();
            case AKZitaReverbParameterMidReleaseTime:
                return midReleaseTimeRamp.getTarget();
            case AKZitaReverbParameterDampingFrequency:
                return dampingFrequencyRamp.getTarget();
            case AKZitaReverbParameterEqualizerFrequency1:
                return equalizerFrequency1Ramp.getTarget();
            case AKZitaReverbParameterEqualizerLevel1:
                return equalizerLevel1Ramp.getTarget();
            case AKZitaReverbParameterEqualizerFrequency2:
                return equalizerFrequency2Ramp.getTarget();
            case AKZitaReverbParameterEqualizerLevel2:
                return equalizerLevel2Ramp.getTarget();
            case AKZitaReverbParameterDryWetMix:
                return dryWetMixRamp.getTarget();
            case AKZitaReverbParameterRampTime:
                return predelayRamp.getRampTime(_sampleRate);
        }
        return 0;
    }

    void init(int _channels, double _sampleRate) override {
        AKSoundpipeDSPBase::init(_channels, _sampleRate);

        sp_zitarev_create(&_zitarev);
        sp_zitarev_init(_sp, _zitarev);


        *_zitarev->in_delay = 60.0;
        *_zitarev->lf_x = 200.0;
        *_zitarev->rt60_low = 3.0;
        *_zitarev->rt60_mid = 2.0;
        *_zitarev->hf_damping = 6000.0;
        *_zitarev->eq1_freq = 315.0;
        *_zitarev->eq1_level = 0.0;
        *_zitarev->eq2_freq = 1500.0;
        *_zitarev->eq2_level = 0.0;
        *_zitarev->mix = 1.0;

    }

    void destroy() {
        sp_zitarev_destroy(&_zitarev);
        AKSoundpipeDSPBase::destroy();
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {

        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            int frameOffset = int(frameIndex + bufferOffset);

            // do gain ramping every 8 samples
            if ((frameOffset & 0x7) == 0) {
                predelayRamp.advanceTo(_now + frameOffset);
                crossoverFrequencyRamp.advanceTo(_now + frameOffset);
                lowReleaseTimeRamp.advanceTo(_now + frameOffset);
                midReleaseTimeRamp.advanceTo(_now + frameOffset);
                dampingFrequencyRamp.advanceTo(_now + frameOffset);
                equalizerFrequency1Ramp.advanceTo(_now + frameOffset);
                equalizerLevel1Ramp.advanceTo(_now + frameOffset);
                equalizerFrequency2Ramp.advanceTo(_now + frameOffset);
                equalizerLevel2Ramp.advanceTo(_now + frameOffset);
                dryWetMixRamp.advanceTo(_now + frameOffset);
            }
            *_zitarev->in_delay = predelayRamp.getValue();
            *_zitarev->lf_x = crossoverFrequencyRamp.getValue();
            *_zitarev->rt60_low = lowReleaseTimeRamp.getValue();
            *_zitarev->rt60_mid = midReleaseTimeRamp.getValue();
            *_zitarev->hf_damping = dampingFrequencyRamp.getValue();
            *_zitarev->eq1_freq = equalizerFrequency1Ramp.getValue();
            *_zitarev->eq1_level = equalizerLevel1Ramp.getValue();
            *_zitarev->eq2_freq = equalizerFrequency2Ramp.getValue();
            *_zitarev->eq2_level = equalizerLevel2Ramp.getValue();
            *_zitarev->mix = dryWetMixRamp.getValue();

            float *tmpin[2];
            float *tmpout[2];
            for (int channel = 0; channel < _nChannels; ++channel) {
                float* in  = (float*)_inBufferListPtr->mBuffers[channel].mData  + frameOffset;
                float* out = (float*)_outBufferListPtr->mBuffers[channel].mData + frameOffset;

                if (channel < 2) {
                    tmpin[channel] = in;
                    tmpout[channel] = out;
                }
                if (!_playing) {
                    *out = *in;
                }
            }
            if (_playing) {
                sp_zitarev_compute(_sp, _zitarev, tmpin[0], tmpin[1], tmpout[0], tmpout[1]);
            }
        }
    }
};

#endif
