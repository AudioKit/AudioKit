//
//  AKZitaReverbDSP.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#include "AKZitaReverbDSP.hpp"
#import "AKLinearParameterRamp.hpp"

extern "C" void* createZitaReverbDSP(int nChannels, double sampleRate) {
    AKZitaReverbDSP* dsp = new AKZitaReverbDSP();
    dsp->init(nChannels, sampleRate);
    return dsp;
}

struct AKZitaReverbDSP::_Internal {
    sp_zitarev *_zitarev;
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

AKZitaReverbDSP::AKZitaReverbDSP() : _private(new _Internal) {
    _private->predelayRamp.setTarget(defaultPredelay, true);
    _private->predelayRamp.setDurationInSamples(defaultRampDurationSamples);
    _private->crossoverFrequencyRamp.setTarget(defaultCrossoverFrequency, true);
    _private->crossoverFrequencyRamp.setDurationInSamples(defaultRampDurationSamples);
    _private->lowReleaseTimeRamp.setTarget(defaultLowReleaseTime, true);
    _private->lowReleaseTimeRamp.setDurationInSamples(defaultRampDurationSamples);
    _private->midReleaseTimeRamp.setTarget(defaultMidReleaseTime, true);
    _private->midReleaseTimeRamp.setDurationInSamples(defaultRampDurationSamples);
    _private->dampingFrequencyRamp.setTarget(defaultDampingFrequency, true);
    _private->dampingFrequencyRamp.setDurationInSamples(defaultRampDurationSamples);
    _private->equalizerFrequency1Ramp.setTarget(defaultEqualizerFrequency1, true);
    _private->equalizerFrequency1Ramp.setDurationInSamples(defaultRampDurationSamples);
    _private->equalizerLevel1Ramp.setTarget(defaultEqualizerLevel1, true);
    _private->equalizerLevel1Ramp.setDurationInSamples(defaultRampDurationSamples);
    _private->equalizerFrequency2Ramp.setTarget(defaultEqualizerFrequency2, true);
    _private->equalizerFrequency2Ramp.setDurationInSamples(defaultRampDurationSamples);
    _private->equalizerLevel2Ramp.setTarget(defaultEqualizerLevel2, true);
    _private->equalizerLevel2Ramp.setDurationInSamples(defaultRampDurationSamples);
    _private->dryWetMixRamp.setTarget(defaultDryWetMix, true);
    _private->dryWetMixRamp.setDurationInSamples(defaultRampDurationSamples);
}

// Uses the ParameterAddress as a key
void AKZitaReverbDSP::setParameter(AUParameterAddress address, AUValue value, bool immediate) {
    switch (address) {
        case AKZitaReverbParameterPredelay:
            _private->predelayRamp.setTarget(clamp(value, predelayLowerBound, predelayUpperBound), immediate);
            break;
        case AKZitaReverbParameterCrossoverFrequency:
            _private->crossoverFrequencyRamp.setTarget(clamp(value, crossoverFrequencyLowerBound, crossoverFrequencyUpperBound), immediate);
            break;
        case AKZitaReverbParameterLowReleaseTime:
            _private->lowReleaseTimeRamp.setTarget(clamp(value, lowReleaseTimeLowerBound, lowReleaseTimeUpperBound), immediate);
            break;
        case AKZitaReverbParameterMidReleaseTime:
            _private->midReleaseTimeRamp.setTarget(clamp(value, midReleaseTimeLowerBound, midReleaseTimeUpperBound), immediate);
            break;
        case AKZitaReverbParameterDampingFrequency:
            _private->dampingFrequencyRamp.setTarget(clamp(value, dampingFrequencyLowerBound, dampingFrequencyUpperBound), immediate);
            break;
        case AKZitaReverbParameterEqualizerFrequency1:
            _private->equalizerFrequency1Ramp.setTarget(clamp(value, equalizerFrequency1LowerBound, equalizerFrequency1UpperBound), immediate);
            break;
        case AKZitaReverbParameterEqualizerLevel1:
            _private->equalizerLevel1Ramp.setTarget(clamp(value, equalizerLevel1LowerBound, equalizerLevel1UpperBound), immediate);
            break;
        case AKZitaReverbParameterEqualizerFrequency2:
            _private->equalizerFrequency2Ramp.setTarget(clamp(value, equalizerFrequency2LowerBound, equalizerFrequency2UpperBound), immediate);
            break;
        case AKZitaReverbParameterEqualizerLevel2:
            _private->equalizerLevel2Ramp.setTarget(clamp(value, equalizerLevel2LowerBound, equalizerLevel2UpperBound), immediate);
            break;
        case AKZitaReverbParameterDryWetMix:
            _private->dryWetMixRamp.setTarget(clamp(value, dryWetMixLowerBound, dryWetMixUpperBound), immediate);
            break;
        case AKZitaReverbParameterRampDuration:
            _private->predelayRamp.setRampDuration(value, _sampleRate);
            _private->crossoverFrequencyRamp.setRampDuration(value, _sampleRate);
            _private->lowReleaseTimeRamp.setRampDuration(value, _sampleRate);
            _private->midReleaseTimeRamp.setRampDuration(value, _sampleRate);
            _private->dampingFrequencyRamp.setRampDuration(value, _sampleRate);
            _private->equalizerFrequency1Ramp.setRampDuration(value, _sampleRate);
            _private->equalizerLevel1Ramp.setRampDuration(value, _sampleRate);
            _private->equalizerFrequency2Ramp.setRampDuration(value, _sampleRate);
            _private->equalizerLevel2Ramp.setRampDuration(value, _sampleRate);
            _private->dryWetMixRamp.setRampDuration(value, _sampleRate);
            break;
    }
}

// Uses the ParameterAddress as a key
float AKZitaReverbDSP::getParameter(uint64_t address) {
    switch (address) {
        case AKZitaReverbParameterPredelay:
            return _private->predelayRamp.getTarget();
        case AKZitaReverbParameterCrossoverFrequency:
            return _private->crossoverFrequencyRamp.getTarget();
        case AKZitaReverbParameterLowReleaseTime:
            return _private->lowReleaseTimeRamp.getTarget();
        case AKZitaReverbParameterMidReleaseTime:
            return _private->midReleaseTimeRamp.getTarget();
        case AKZitaReverbParameterDampingFrequency:
            return _private->dampingFrequencyRamp.getTarget();
        case AKZitaReverbParameterEqualizerFrequency1:
            return _private->equalizerFrequency1Ramp.getTarget();
        case AKZitaReverbParameterEqualizerLevel1:
            return _private->equalizerLevel1Ramp.getTarget();
        case AKZitaReverbParameterEqualizerFrequency2:
            return _private->equalizerFrequency2Ramp.getTarget();
        case AKZitaReverbParameterEqualizerLevel2:
            return _private->equalizerLevel2Ramp.getTarget();
        case AKZitaReverbParameterDryWetMix:
            return _private->dryWetMixRamp.getTarget();
        case AKZitaReverbParameterRampDuration:
            return _private->predelayRamp.getRampDuration(_sampleRate);
    }
    return 0;
}

void AKZitaReverbDSP::init(int _channels, double _sampleRate) {
    AKSoundpipeDSPBase::init(_channels, _sampleRate);
    sp_zitarev_create(&_private->_zitarev);
    sp_zitarev_init(_sp, _private->_zitarev);
    *_private->_zitarev->in_delay = defaultPredelay;
    *_private->_zitarev->lf_x = defaultCrossoverFrequency;
    *_private->_zitarev->rt60_low = defaultLowReleaseTime;
    *_private->_zitarev->rt60_mid = defaultMidReleaseTime;
    *_private->_zitarev->hf_damping = defaultDampingFrequency;
    *_private->_zitarev->eq1_freq = defaultEqualizerFrequency1;
    *_private->_zitarev->eq1_level = defaultEqualizerLevel1;
    *_private->_zitarev->eq2_freq = defaultEqualizerFrequency2;
    *_private->_zitarev->eq2_level = defaultEqualizerLevel2;
    *_private->_zitarev->mix = defaultDryWetMix;
}

void AKZitaReverbDSP::destroy() {
    sp_zitarev_destroy(&_private->_zitarev);
    AKSoundpipeDSPBase::destroy();
}

void AKZitaReverbDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);

        // do ramping every 8 samples
        if ((frameOffset & 0x7) == 0) {
            _private->predelayRamp.advanceTo(_now + frameOffset);
            _private->crossoverFrequencyRamp.advanceTo(_now + frameOffset);
            _private->lowReleaseTimeRamp.advanceTo(_now + frameOffset);
            _private->midReleaseTimeRamp.advanceTo(_now + frameOffset);
            _private->dampingFrequencyRamp.advanceTo(_now + frameOffset);
            _private->equalizerFrequency1Ramp.advanceTo(_now + frameOffset);
            _private->equalizerLevel1Ramp.advanceTo(_now + frameOffset);
            _private->equalizerFrequency2Ramp.advanceTo(_now + frameOffset);
            _private->equalizerLevel2Ramp.advanceTo(_now + frameOffset);
            _private->dryWetMixRamp.advanceTo(_now + frameOffset);
        }

        *_private->_zitarev->in_delay = _private->predelayRamp.getValue();
        *_private->_zitarev->lf_x = _private->crossoverFrequencyRamp.getValue();
        *_private->_zitarev->rt60_low = _private->lowReleaseTimeRamp.getValue();
        *_private->_zitarev->rt60_mid = _private->midReleaseTimeRamp.getValue();
        *_private->_zitarev->hf_damping = _private->dampingFrequencyRamp.getValue();
        *_private->_zitarev->eq1_freq = _private->equalizerFrequency1Ramp.getValue();
        *_private->_zitarev->eq1_level = _private->equalizerLevel1Ramp.getValue();
        *_private->_zitarev->eq2_freq = _private->equalizerFrequency2Ramp.getValue();
        *_private->_zitarev->eq2_level = _private->equalizerLevel2Ramp.getValue();
        *_private->_zitarev->mix = _private->dryWetMixRamp.getValue();

        float *tmpin[2];
        float *tmpout[2];
        for (int channel = 0; channel < _nChannels; ++channel) {
            float* in  = (float *)_inBufferListPtr->mBuffers[channel].mData  + frameOffset;
            float* out = (float *)_outBufferListPtr->mBuffers[channel].mData + frameOffset;
            if (channel < 2) {
                tmpin[channel] = in;
                tmpout[channel] = out;
            }
            if (!_playing) {
                *out = *in;
            }
            
        }
        if (_playing) {
            sp_zitarev_compute(_sp, _private->_zitarev, tmpin[0], tmpin[1], tmpout[0], tmpout[1]);
        }
    }
}
