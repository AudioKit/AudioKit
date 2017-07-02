//
//  AKZitaReverbDSPKernel.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

#pragma once

#import "AKSoundpipeKernel.hpp"

enum {
    delayAddress = 0,
    crossoverFrequencyAddress = 1,
    lowReleaseTimeAddress = 2,
    midReleaseTimeAddress = 3,
    dampingFrequencyAddress = 4,
    equalizerFrequency1Address = 5,
    equalizerLevel1Address = 6,
    equalizerFrequency2Address = 7,
    equalizerLevel2Address = 8,
    dryWetMixAddress = 9
};

class AKZitaReverbDSPKernel : public AKSoundpipeKernel, public AKBuffered {
public:
    // MARK: Member Functions

    AKZitaReverbDSPKernel() {}

    void init(int _channels, double _sampleRate) override {
        AKSoundpipeKernel::init(_channels, _sampleRate);

        sp_zitarev_create(&zitarev0);
        sp_zitarev_init(sp, zitarev0);
        *zitarev0->in_delay = 60.0;
        *zitarev0->lf_x = 200.0;
        *zitarev0->rt60_low = 3.0;
        *zitarev0->rt60_mid = 2.0;
        *zitarev0->hf_damping = 6000.0;
        *zitarev0->eq1_freq = 315.0;
        *zitarev0->eq1_level = 0.0;
        *zitarev0->eq2_freq = 1500.0;
        *zitarev0->eq2_level = 0.0;
        *zitarev0->mix = 1.0;

        delayRamper.init();
        crossoverFrequencyRamper.init();
        lowReleaseTimeRamper.init();
        midReleaseTimeRamper.init();
        dampingFrequencyRamper.init();
        equalizerFrequency1Ramper.init();
        equalizerLevel1Ramper.init();
        equalizerFrequency2Ramper.init();
        equalizerLevel2Ramper.init();
        dryWetMixRamper.init();
    }

    void start() {
        started = true;
    }

    void stop() {
        started = false;
    }

    void destroy() {
        sp_zitarev_destroy(&zitarev0);
        AKSoundpipeKernel::destroy();
    }

    void reset() {
        resetted = true;
        delayRamper.reset();
        crossoverFrequencyRamper.reset();
        lowReleaseTimeRamper.reset();
        midReleaseTimeRamper.reset();
        dampingFrequencyRamper.reset();
        equalizerFrequency1Ramper.reset();
        equalizerLevel1Ramper.reset();
        equalizerFrequency2Ramper.reset();
        equalizerLevel2Ramper.reset();
        dryWetMixRamper.reset();
    }

    void setDelay(float value) {
        delay = clamp(value, 0.0f, 200.0f);
        delayRamper.setImmediate(delay);
    }

    void setCrossoverFrequency(float value) {
        crossoverFrequency = clamp(value, 10.0f, 1000.0f);
        crossoverFrequencyRamper.setImmediate(crossoverFrequency);
    }

    void setLowReleaseTime(float value) {
        lowReleaseTime = clamp(value, 0.0f, 10.0f);
        lowReleaseTimeRamper.setImmediate(lowReleaseTime);
    }

    void setMidReleaseTime(float value) {
        midReleaseTime = clamp(value, 0.0f, 10.0f);
        midReleaseTimeRamper.setImmediate(midReleaseTime);
    }

    void setDampingFrequency(float value) {
        dampingFrequency = clamp(value, 10.0f, 22050.0f);
        dampingFrequencyRamper.setImmediate(dampingFrequency);
    }

    void setEqualizerFrequency1(float value) {
        equalizerFrequency1 = clamp(value, 10.0f, 1000.0f);
        equalizerFrequency1Ramper.setImmediate(equalizerFrequency1);
    }

    void setEqualizerLevel1(float value) {
        equalizerLevel1 = clamp(value, -100.0f, 10.0f);
        equalizerLevel1Ramper.setImmediate(equalizerLevel1);
    }

    void setEqualizerFrequency2(float value) {
        equalizerFrequency2 = clamp(value, 10.0f, 22050.0f);
        equalizerFrequency2Ramper.setImmediate(equalizerFrequency2);
    }

    void setEqualizerLevel2(float value) {
        equalizerLevel2 = clamp(value, -100.0f, 10.0f);
        equalizerLevel2Ramper.setImmediate(equalizerLevel2);
    }

    void setDryWetMix(float value) {
        dryWetMix = clamp(value, 0.0f, 1.0f);
        dryWetMixRamper.setImmediate(dryWetMix);
    }


    void setParameter(AUParameterAddress address, AUValue value) {
        switch (address) {
            case delayAddress:
                delayRamper.setUIValue(clamp(value, 0.0f, 200.0f));
                break;

            case crossoverFrequencyAddress:
                crossoverFrequencyRamper.setUIValue(clamp(value, 10.0f, 1000.0f));
                break;

            case lowReleaseTimeAddress:
                lowReleaseTimeRamper.setUIValue(clamp(value, 0.0f, 10.0f));
                break;

            case midReleaseTimeAddress:
                midReleaseTimeRamper.setUIValue(clamp(value, 0.0f, 10.0f));
                break;

            case dampingFrequencyAddress:
                dampingFrequencyRamper.setUIValue(clamp(value, 10.0f, 22050.0f));
                break;

            case equalizerFrequency1Address:
                equalizerFrequency1Ramper.setUIValue(clamp(value, 10.0f, 1000.0f));
                break;

            case equalizerLevel1Address:
                equalizerLevel1Ramper.setUIValue(clamp(value, -100.0f, 10.0f));
                break;

            case equalizerFrequency2Address:
                equalizerFrequency2Ramper.setUIValue(clamp(value, 10.0f, 22050.0f));
                break;

            case equalizerLevel2Address:
                equalizerLevel2Ramper.setUIValue(clamp(value, -100.0f, 10.0f));
                break;

            case dryWetMixAddress:
                dryWetMixRamper.setUIValue(clamp(value, 0.0f, 1.0f));
                break;

        }
    }

    AUValue getParameter(AUParameterAddress address) {
        switch (address) {
            case delayAddress:
                return delayRamper.getUIValue();

            case crossoverFrequencyAddress:
                return crossoverFrequencyRamper.getUIValue();

            case lowReleaseTimeAddress:
                return lowReleaseTimeRamper.getUIValue();

            case midReleaseTimeAddress:
                return midReleaseTimeRamper.getUIValue();

            case dampingFrequencyAddress:
                return dampingFrequencyRamper.getUIValue();

            case equalizerFrequency1Address:
                return equalizerFrequency1Ramper.getUIValue();

            case equalizerLevel1Address:
                return equalizerLevel1Ramper.getUIValue();

            case equalizerFrequency2Address:
                return equalizerFrequency2Ramper.getUIValue();

            case equalizerLevel2Address:
                return equalizerLevel2Ramper.getUIValue();

            case dryWetMixAddress:
                return dryWetMixRamper.getUIValue();

            default: return 0.0f;
        }
    }

    void startRamp(AUParameterAddress address, AUValue value, AUAudioFrameCount duration) override {
        switch (address) {
            case delayAddress:
                delayRamper.startRamp(clamp(value, 0.0f, 200.0f), duration);
                break;

            case crossoverFrequencyAddress:
                crossoverFrequencyRamper.startRamp(clamp(value, 10.0f, 1000.0f), duration);
                break;

            case lowReleaseTimeAddress:
                lowReleaseTimeRamper.startRamp(clamp(value, 0.0f, 10.0f), duration);
                break;

            case midReleaseTimeAddress:
                midReleaseTimeRamper.startRamp(clamp(value, 0.0f, 10.0f), duration);
                break;

            case dampingFrequencyAddress:
                dampingFrequencyRamper.startRamp(clamp(value, 10.0f, 22050.0f), duration);
                break;

            case equalizerFrequency1Address:
                equalizerFrequency1Ramper.startRamp(clamp(value, 10.0f, 1000.0f), duration);
                break;

            case equalizerLevel1Address:
                equalizerLevel1Ramper.startRamp(clamp(value, -100.0f, 10.0f), duration);
                break;

            case equalizerFrequency2Address:
                equalizerFrequency2Ramper.startRamp(clamp(value, 10.0f, 22050.0f), duration);
                break;

            case equalizerLevel2Address:
                equalizerLevel2Ramper.startRamp(clamp(value, -100.0f, 10.0f), duration);
                break;

            case dryWetMixAddress:
                dryWetMixRamper.startRamp(clamp(value, 0.0f, 1.0f), duration);
                break;

        }
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {

        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {

            int frameOffset = int(frameIndex + bufferOffset);

            delay = delayRamper.getAndStep();
            *zitarev0->in_delay = (float)delay;
            crossoverFrequency = crossoverFrequencyRamper.getAndStep();
            *zitarev0->lf_x = (float)crossoverFrequency;
            lowReleaseTime = lowReleaseTimeRamper.getAndStep();
            *zitarev0->rt60_low = (float)lowReleaseTime;
            midReleaseTime = midReleaseTimeRamper.getAndStep();
            *zitarev0->rt60_mid = (float)midReleaseTime;
            dampingFrequency = dampingFrequencyRamper.getAndStep();
            *zitarev0->hf_damping = (float)dampingFrequency;
            equalizerFrequency1 = equalizerFrequency1Ramper.getAndStep();
            *zitarev0->eq1_freq = (float)equalizerFrequency1;
            equalizerLevel1 = equalizerLevel1Ramper.getAndStep();
            *zitarev0->eq1_level = (float)equalizerLevel1;
            equalizerFrequency2 = equalizerFrequency2Ramper.getAndStep();
            *zitarev0->eq2_freq = (float)equalizerFrequency2;
            equalizerLevel2 = equalizerLevel2Ramper.getAndStep();
            *zitarev0->eq2_level = (float)equalizerLevel2;
            dryWetMix = dryWetMixRamper.getAndStep();
            *zitarev0->mix = (float)dryWetMix;

            float *tmpin[2];
            float *tmpout[2];
            for (int channel = 0; channel < channels; ++channel) {
                float *in  = (float *)inBufferListPtr->mBuffers[channel].mData  + frameOffset;
                float *out = (float *)outBufferListPtr->mBuffers[channel].mData + frameOffset;
                
                if (channel < 2) {
                    tmpin[channel] = in;
                    tmpout[channel] = out;
                }
            }
            if (started) {
                sp_zitarev_compute(sp, zitarev0, tmpin[0], tmpin[1], tmpout[0], tmpout[1]);
            } else {
                tmpout[0] = tmpin[0];
                tmpout[1] = tmpin[1];
            }
        }
    }

    // MARK: Member Variables

private:

    sp_zitarev *zitarev0;

    float delay = 60.0;
    float crossoverFrequency = 200.0;
    float lowReleaseTime = 3.0;
    float midReleaseTime = 2.0;
    float dampingFrequency = 6000.0;
    float equalizerFrequency1 = 315.0;
    float equalizerLevel1 = 0.0;
    float equalizerFrequency2 = 1500.0;
    float equalizerLevel2 = 0.0;
    float dryWetMix = 1.0;

public:
    bool started = true;
    bool resetted = false;
    ParameterRamper delayRamper = 60.0;
    ParameterRamper crossoverFrequencyRamper = 200.0;
    ParameterRamper lowReleaseTimeRamper = 3.0;
    ParameterRamper midReleaseTimeRamper = 2.0;
    ParameterRamper dampingFrequencyRamper = 6000.0;
    ParameterRamper equalizerFrequency1Ramper = 315.0;
    ParameterRamper equalizerLevel1Ramper = 0.0;
    ParameterRamper equalizerFrequency2Ramper = 1500.0;
    ParameterRamper equalizerLevel2Ramper = 0.0;
    ParameterRamper dryWetMixRamper = 1.0;
};
