//
//  AKAmplitudeEnvelopeDSP.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once

#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(AUParameterAddress, AKAmplitudeEnvelopeParameter) {
    AKAmplitudeEnvelopeParameterAttackDuration,
    AKAmplitudeEnvelopeParameterDecayDuration,
    AKAmplitudeEnvelopeParameterSustainLevel,
    AKAmplitudeEnvelopeParameterReleaseDuration,
    AKAmplitudeEnvelopeParameterRampDuration
};

#import "AKLinearParameterRamp.hpp"  // have to put this here to get it included in umbrella header

#ifndef __cplusplus

AKDSPRef createAmplitudeEnvelopeDSP(int channelCount, double sampleRate);

#else

#import "AKSoundpipeDSPBase.hpp"

class AKAmplitudeEnvelopeDSP : public AKSoundpipeDSPBase {
    sp_adsr *_adsr;

private:
    float internalGate = 0;
    float amp = 0;
    AKLinearParameterRamp attackDurationRamp;
    AKLinearParameterRamp decayDurationRamp;
    AKLinearParameterRamp sustainLevelRamp;
    AKLinearParameterRamp releaseDurationRamp;

public:
    AKAmplitudeEnvelopeDSP() {
        attackDurationRamp.setTarget(0.1, true);
        attackDurationRamp.setDurationInSamples(10000);
        decayDurationRamp.setTarget(0.1, true);
        decayDurationRamp.setDurationInSamples(10000);
        sustainLevelRamp.setTarget(1.0, true);
        sustainLevelRamp.setDurationInSamples(10000);
        releaseDurationRamp.setTarget(0.1, true);
        releaseDurationRamp.setDurationInSamples(10000);
    }

    /** Uses the ParameterAddress as a key */
    void setParameter(AUParameterAddress address, float value, bool immediate) override {
        switch (address) {
            case AKAmplitudeEnvelopeParameterAttackDuration:
                attackDurationRamp.setTarget(value, immediate);
                break;
            case AKAmplitudeEnvelopeParameterDecayDuration:
                decayDurationRamp.setTarget(value, immediate);
                break;
            case AKAmplitudeEnvelopeParameterSustainLevel:
                sustainLevelRamp.setTarget(value, immediate);
                break;
            case AKAmplitudeEnvelopeParameterReleaseDuration:
                releaseDurationRamp.setTarget(value, immediate);
                break;
            case AKAmplitudeEnvelopeParameterRampDuration:
                attackDurationRamp.setRampDuration(value, sampleRate);
                decayDurationRamp.setRampDuration(value, sampleRate);
                sustainLevelRamp.setRampDuration(value, sampleRate);
                releaseDurationRamp.setRampDuration(value, sampleRate);
                break;
        }
    }

    /** Uses the ParameterAddress as a key */
    float getParameter(AUParameterAddress address) override {
        switch (address) {
            case AKAmplitudeEnvelopeParameterAttackDuration:
                return attackDurationRamp.getTarget();
            case AKAmplitudeEnvelopeParameterDecayDuration:
                return decayDurationRamp.getTarget();
            case AKAmplitudeEnvelopeParameterSustainLevel:
                return sustainLevelRamp.getTarget();
            case AKAmplitudeEnvelopeParameterReleaseDuration:
                return releaseDurationRamp.getTarget();
            case AKAmplitudeEnvelopeParameterRampDuration:
                return attackDurationRamp.getRampDuration(sampleRate);
                return decayDurationRamp.getRampDuration(sampleRate);
                return sustainLevelRamp.getRampDuration(sampleRate);
                return releaseDurationRamp.getRampDuration(sampleRate);
        }
        return 0;
    }

    void init(int channelCount, double sampleRate) override {
        AKSoundpipeDSPBase::init(channelCount, sampleRate);
        sp_adsr_create(&_adsr);
    }

    void start() override {
        internalGate = 1;
        isStarted = true;
    }

    void stop() override {
        internalGate = 0;
        isStarted = false;
    }

    void deinit() override {
        sp_adsr_destroy(&_adsr);
    }

    void reset() override {
        sp_adsr_init(sp, _adsr);
        _adsr->atk = 0.1;
        _adsr->dec = 0.1;
        _adsr->sus = 1.0;
        _adsr->rel = 0.1;
    }

    void process(uint32_t frameCount, uint32_t bufferOffset) override {

        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            int frameOffset = int(frameIndex + bufferOffset);

            // do ramping every 8 samples
            if ((frameOffset & 0x7) == 0) {
                attackDurationRamp.advanceTo(now + frameOffset);
                decayDurationRamp.advanceTo(now + frameOffset);
                sustainLevelRamp.advanceTo(now + frameOffset);
                releaseDurationRamp.advanceTo(now + frameOffset);
            }
            _adsr->atk = attackDurationRamp.getValue();
            _adsr->dec = decayDurationRamp.getValue();
            _adsr->sus = sustainLevelRamp.getValue();
            _adsr->rel = releaseDurationRamp.getValue();

            sp_adsr_compute(sp, _adsr, &internalGate, &amp);

            for (int channel = 0; channel < channelCount; ++channel) {
                float *in  = (float *)inBufferListPtr->mBuffers[channel].mData  + frameOffset;
                float *out = (float *)outBufferListPtr->mBuffers[channel].mData + frameOffset;
                *out = *in * amp;
            }
        }
    }
};

#endif
