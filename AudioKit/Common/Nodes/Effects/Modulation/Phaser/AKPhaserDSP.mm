//
//  AKPhaserDSP.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#include "AKPhaserDSP.hpp"
#import "AKLinearParameterRamp.hpp"

extern "C" void* createPhaserDSP(int nChannels, double sampleRate) {
    AKPhaserDSP* dsp = new AKPhaserDSP();
    dsp->init(nChannels, sampleRate);
    return dsp;
}

struct AKPhaserDSP::_Internal {
    sp_phaser *_phaser;
    AKLinearParameterRamp notchMinimumFrequencyRamp;
    AKLinearParameterRamp notchMaximumFrequencyRamp;
    AKLinearParameterRamp notchWidthRamp;
    AKLinearParameterRamp notchFrequencyRamp;
    AKLinearParameterRamp vibratoModeRamp;
    AKLinearParameterRamp depthRamp;
    AKLinearParameterRamp feedbackRamp;
    AKLinearParameterRamp invertedRamp;
    AKLinearParameterRamp lfoBPMRamp;
};

AKPhaserDSP::AKPhaserDSP() : _private(new _Internal) {
    _private->notchMinimumFrequencyRamp.setTarget(defaultNotchMinimumFrequency, true);
    _private->notchMinimumFrequencyRamp.setDurationInSamples(defaultRampDurationSamples);
    _private->notchMaximumFrequencyRamp.setTarget(defaultNotchMaximumFrequency, true);
    _private->notchMaximumFrequencyRamp.setDurationInSamples(defaultRampDurationSamples);
    _private->notchWidthRamp.setTarget(defaultNotchWidth, true);
    _private->notchWidthRamp.setDurationInSamples(defaultRampDurationSamples);
    _private->notchFrequencyRamp.setTarget(defaultNotchFrequency, true);
    _private->notchFrequencyRamp.setDurationInSamples(defaultRampDurationSamples);
    _private->vibratoModeRamp.setTarget(defaultVibratoMode, true);
    _private->vibratoModeRamp.setDurationInSamples(defaultRampDurationSamples);
    _private->depthRamp.setTarget(defaultDepth, true);
    _private->depthRamp.setDurationInSamples(defaultRampDurationSamples);
    _private->feedbackRamp.setTarget(defaultFeedback, true);
    _private->feedbackRamp.setDurationInSamples(defaultRampDurationSamples);
    _private->invertedRamp.setTarget(defaultInverted, true);
    _private->invertedRamp.setDurationInSamples(defaultRampDurationSamples);
    _private->lfoBPMRamp.setTarget(defaultLfoBPM, true);
    _private->lfoBPMRamp.setDurationInSamples(defaultRampDurationSamples);
}

// Uses the ParameterAddress as a key
void AKPhaserDSP::setParameter(AUParameterAddress address, AUValue value, bool immediate) {
    switch (address) {
        case AKPhaserParameterNotchMinimumFrequency:
            _private->notchMinimumFrequencyRamp.setTarget(clamp(value, notchMinimumFrequencyLowerBound, notchMinimumFrequencyUpperBound), immediate);
            break;
        case AKPhaserParameterNotchMaximumFrequency:
            _private->notchMaximumFrequencyRamp.setTarget(clamp(value, notchMaximumFrequencyLowerBound, notchMaximumFrequencyUpperBound), immediate);
            break;
        case AKPhaserParameterNotchWidth:
            _private->notchWidthRamp.setTarget(clamp(value, notchWidthLowerBound, notchWidthUpperBound), immediate);
            break;
        case AKPhaserParameterNotchFrequency:
            _private->notchFrequencyRamp.setTarget(clamp(value, notchFrequencyLowerBound, notchFrequencyUpperBound), immediate);
            break;
        case AKPhaserParameterVibratoMode:
            _private->vibratoModeRamp.setTarget(clamp(value, vibratoModeLowerBound, vibratoModeUpperBound), immediate);
            break;
        case AKPhaserParameterDepth:
            _private->depthRamp.setTarget(clamp(value, depthLowerBound, depthUpperBound), immediate);
            break;
        case AKPhaserParameterFeedback:
            _private->feedbackRamp.setTarget(clamp(value, feedbackLowerBound, feedbackUpperBound), immediate);
            break;
        case AKPhaserParameterInverted:
            _private->invertedRamp.setTarget(clamp(value, invertedLowerBound, invertedUpperBound), immediate);
            break;
        case AKPhaserParameterLfoBPM:
            _private->lfoBPMRamp.setTarget(clamp(value, lfoBPMLowerBound, lfoBPMUpperBound), immediate);
            break;
        case AKPhaserParameterRampDuration:
            _private->notchMinimumFrequencyRamp.setRampDuration(value, _sampleRate);
            _private->notchMaximumFrequencyRamp.setRampDuration(value, _sampleRate);
            _private->notchWidthRamp.setRampDuration(value, _sampleRate);
            _private->notchFrequencyRamp.setRampDuration(value, _sampleRate);
            _private->vibratoModeRamp.setRampDuration(value, _sampleRate);
            _private->depthRamp.setRampDuration(value, _sampleRate);
            _private->feedbackRamp.setRampDuration(value, _sampleRate);
            _private->invertedRamp.setRampDuration(value, _sampleRate);
            _private->lfoBPMRamp.setRampDuration(value, _sampleRate);
            break;
    }
}

// Uses the ParameterAddress as a key
float AKPhaserDSP::getParameter(uint64_t address) {
    switch (address) {
        case AKPhaserParameterNotchMinimumFrequency:
            return _private->notchMinimumFrequencyRamp.getTarget();
        case AKPhaserParameterNotchMaximumFrequency:
            return _private->notchMaximumFrequencyRamp.getTarget();
        case AKPhaserParameterNotchWidth:
            return _private->notchWidthRamp.getTarget();
        case AKPhaserParameterNotchFrequency:
            return _private->notchFrequencyRamp.getTarget();
        case AKPhaserParameterVibratoMode:
            return _private->vibratoModeRamp.getTarget();
        case AKPhaserParameterDepth:
            return _private->depthRamp.getTarget();
        case AKPhaserParameterFeedback:
            return _private->feedbackRamp.getTarget();
        case AKPhaserParameterInverted:
            return _private->invertedRamp.getTarget();
        case AKPhaserParameterLfoBPM:
            return _private->lfoBPMRamp.getTarget();
        case AKPhaserParameterRampDuration:
            return _private->notchMinimumFrequencyRamp.getRampDuration(_sampleRate);
    }
    return 0;
}

void AKPhaserDSP::init(int _channels, double _sampleRate) {
    AKSoundpipeDSPBase::init(_channels, _sampleRate);
    sp_phaser_create(&_private->_phaser);
    sp_phaser_init(_sp, _private->_phaser);
    *_private->_phaser->MinNotch1Freq = defaultNotchMinimumFrequency;
    *_private->_phaser->MaxNotch1Freq = defaultNotchMaximumFrequency;
    *_private->_phaser->Notch_width = defaultNotchWidth;
    *_private->_phaser->NotchFreq = defaultNotchFrequency;
    *_private->_phaser->VibratoMode = defaultVibratoMode;
    *_private->_phaser->depth = defaultDepth;
    *_private->_phaser->feedback_gain = defaultFeedback;
    *_private->_phaser->invert = defaultInverted;
    *_private->_phaser->lfobpm = defaultLfoBPM;
}

void AKPhaserDSP::destroy() {
    sp_phaser_destroy(&_private->_phaser);
    AKSoundpipeDSPBase::destroy();
}

void AKPhaserDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);

        // do ramping every 8 samples
        if ((frameOffset & 0x7) == 0) {
            _private->notchMinimumFrequencyRamp.advanceTo(_now + frameOffset);
            _private->notchMaximumFrequencyRamp.advanceTo(_now + frameOffset);
            _private->notchWidthRamp.advanceTo(_now + frameOffset);
            _private->notchFrequencyRamp.advanceTo(_now + frameOffset);
            _private->vibratoModeRamp.advanceTo(_now + frameOffset);
            _private->depthRamp.advanceTo(_now + frameOffset);
            _private->feedbackRamp.advanceTo(_now + frameOffset);
            _private->invertedRamp.advanceTo(_now + frameOffset);
            _private->lfoBPMRamp.advanceTo(_now + frameOffset);
        }

        *_private->_phaser->MinNotch1Freq = _private->notchMinimumFrequencyRamp.getValue();
        *_private->_phaser->MaxNotch1Freq = _private->notchMaximumFrequencyRamp.getValue();
        *_private->_phaser->Notch_width = _private->notchWidthRamp.getValue();
        *_private->_phaser->NotchFreq = _private->notchFrequencyRamp.getValue();
        *_private->_phaser->VibratoMode = _private->vibratoModeRamp.getValue();
        *_private->_phaser->depth = _private->depthRamp.getValue();
        *_private->_phaser->feedback_gain = _private->feedbackRamp.getValue();
        *_private->_phaser->invert = _private->invertedRamp.getValue();
        *_private->_phaser->lfobpm = _private->lfoBPMRamp.getValue();

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
            sp_phaser_compute(_sp, _private->_phaser, tmpin[0], tmpin[1], tmpout[0], tmpout[1]);
        }
    }
}
