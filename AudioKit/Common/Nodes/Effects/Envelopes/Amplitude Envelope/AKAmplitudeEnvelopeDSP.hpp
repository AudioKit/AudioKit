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
    AKAmplitudeEnvelopeParameterRampTime
};

#import "AKLinearParameterRamp.hpp"  // have to put this here to get it included in umbrella header

#ifndef __cplusplus

void* createAmplitudeEnvelopeDSP(int nChannels, double sampleRate);

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
            case AKAmplitudeEnvelopeParameterRampTime:
                attackDurationRamp.setRampTime(value, _sampleRate);
                decayDurationRamp.setRampTime(value, _sampleRate);
                sustainLevelRamp.setRampTime(value, _sampleRate);
                releaseDurationRamp.setRampTime(value, _sampleRate);
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
            case AKAmplitudeEnvelopeParameterRampTime:
                return attackDurationRamp.getRampTime(_sampleRate);
                return decayDurationRamp.getRampTime(_sampleRate);
                return sustainLevelRamp.getRampTime(_sampleRate);
                return releaseDurationRamp.getRampTime(_sampleRate);
        }
        return 0;
    }

    void init(int _channels, double _sampleRate) override {
        AKSoundpipeDSPBase::init(_channels, _sampleRate);
        sp_adsr_create(&_adsr);
    }

    void start() override {
        internalGate = 1;
        _playing = true;
    }

    void stop() override {
        internalGate = 0;
        _playing = false;
    }

    void destroy() {
        sp_adsr_destroy(&_adsr);
        AKSoundpipeDSPBase::destroy();
    }

    void reset() override {
        sp_adsr_init(_sp, _adsr);
        _adsr->atk = 0.1;
        _adsr->dec = 0.1;
        _adsr->sus = 1.0;
        _adsr->rel = 0.1;
        bool immediate = true;
        attackDurationRamp.setTarget(0.1, immediate);
        decayDurationRamp.setTarget(0.1, immediate);
        sustainLevelRamp.setTarget(1.0, immediate);
        releaseDurationRamp.setTarget(0.1, immediate);
    }

    void process(uint32_t frameCount, uint32_t bufferOffset) override {

        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            int frameOffset = int(frameIndex + bufferOffset);

            // do ramping every 8 samples
            if ((frameOffset & 0x7) == 0) {
                attackDurationRamp.advanceTo(_now + frameOffset);
                decayDurationRamp.advanceTo(_now + frameOffset);
                sustainLevelRamp.advanceTo(_now + frameOffset);
                releaseDurationRamp.advanceTo(_now + frameOffset);
            }
            _adsr->atk = attackDurationRamp.getValue();
            _adsr->dec = decayDurationRamp.getValue();
            _adsr->sus = sustainLevelRamp.getValue();
            _adsr->rel = releaseDurationRamp.getValue();

            sp_adsr_compute(_sp, _adsr, &internalGate, &amp);

            for (int channel = 0; channel < _nChannels; ++channel) {
                float *in  = (float *)_inBufferListPtr->mBuffers[channel].mData  + frameOffset;
                float *out = (float *)_outBufferListPtr->mBuffers[channel].mData + frameOffset;
                *out = *in * amp;
            }
        }
    }
};

#endif
