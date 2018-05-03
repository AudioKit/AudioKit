//
//  AKThreePoleLowpassFilterDSP.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#include "AKThreePoleLowpassFilterDSP.hpp"
#import "AKLinearParameterRamp.hpp"

extern "C" void* createThreePoleLowpassFilterDSP(int nChannels, double sampleRate) {
    AKThreePoleLowpassFilterDSP* dsp = new AKThreePoleLowpassFilterDSP();
    dsp->init(nChannels, sampleRate);
    return dsp;
}

struct AKThreePoleLowpassFilterDSP::_Internal {
    sp_lpf18 *_lpf180;
    sp_lpf18 *_lpf181;
    AKLinearParameterRamp distortionRamp;
    AKLinearParameterRamp cutoffFrequencyRamp;
    AKLinearParameterRamp resonanceRamp;
};

AKThreePoleLowpassFilterDSP::AKThreePoleLowpassFilterDSP() : _private(new _Internal) {
    _private->distortionRamp.setTarget(defaultDistortion, true);
    _private->distortionRamp.setDurationInSamples(defaultRampDurationSamples);
    _private->cutoffFrequencyRamp.setTarget(defaultCutoffFrequency, true);
    _private->cutoffFrequencyRamp.setDurationInSamples(defaultRampDurationSamples);
    _private->resonanceRamp.setTarget(defaultResonance, true);
    _private->resonanceRamp.setDurationInSamples(defaultRampDurationSamples);
}

// Uses the ParameterAddress as a key
void AKThreePoleLowpassFilterDSP::setParameter(AUParameterAddress address, AUValue value, bool immediate) {
    switch (address) {
        case AKThreePoleLowpassFilterParameterDistortion:
            _private->distortionRamp.setTarget(clamp(value, distortionLowerBound, distortionUpperBound), immediate);
            break;
        case AKThreePoleLowpassFilterParameterCutoffFrequency:
            _private->cutoffFrequencyRamp.setTarget(clamp(value, cutoffFrequencyLowerBound, cutoffFrequencyUpperBound), immediate);
            break;
        case AKThreePoleLowpassFilterParameterResonance:
            _private->resonanceRamp.setTarget(clamp(value, resonanceLowerBound, resonanceUpperBound), immediate);
            break;
        case AKThreePoleLowpassFilterParameterRampDuration:
            _private->distortionRamp.setRampDuration(value, _sampleRate);
            _private->cutoffFrequencyRamp.setRampDuration(value, _sampleRate);
            _private->resonanceRamp.setRampDuration(value, _sampleRate);
            break;
    }
}

// Uses the ParameterAddress as a key
float AKThreePoleLowpassFilterDSP::getParameter(uint64_t address) {
    switch (address) {
        case AKThreePoleLowpassFilterParameterDistortion:
            return _private->distortionRamp.getTarget();
        case AKThreePoleLowpassFilterParameterCutoffFrequency:
            return _private->cutoffFrequencyRamp.getTarget();
        case AKThreePoleLowpassFilterParameterResonance:
            return _private->resonanceRamp.getTarget();
        case AKThreePoleLowpassFilterParameterRampDuration:
            return _private->distortionRamp.getRampDuration(_sampleRate);
    }
    return 0;
}

void AKThreePoleLowpassFilterDSP::init(int _channels, double _sampleRate) {
    AKSoundpipeDSPBase::init(_channels, _sampleRate);
    sp_lpf18_create(&_private->_lpf180);
    sp_lpf18_init(_sp, _private->_lpf180);
    sp_lpf18_create(&_private->_lpf181);
    sp_lpf18_init(_sp, _private->_lpf181);
    _private->_lpf180->dist = defaultDistortion;
    _private->_lpf181->dist = defaultDistortion;
    _private->_lpf180->cutoff = defaultCutoffFrequency;
    _private->_lpf181->cutoff = defaultCutoffFrequency;
    _private->_lpf180->res = defaultResonance;
    _private->_lpf181->res = defaultResonance;
}

void AKThreePoleLowpassFilterDSP::destroy() {
    sp_lpf18_destroy(&_private->_lpf180);
    sp_lpf18_destroy(&_private->_lpf181);
    AKSoundpipeDSPBase::destroy();
}

void AKThreePoleLowpassFilterDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);

        // do ramping every 8 samples
        if ((frameOffset & 0x7) == 0) {
            _private->distortionRamp.advanceTo(_now + frameOffset);
            _private->cutoffFrequencyRamp.advanceTo(_now + frameOffset);
            _private->resonanceRamp.advanceTo(_now + frameOffset);
        }

        _private->_lpf180->dist = _private->distortionRamp.getValue();
        _private->_lpf181->dist = _private->distortionRamp.getValue();
        _private->_lpf180->cutoff = _private->cutoffFrequencyRamp.getValue();
        _private->_lpf181->cutoff = _private->cutoffFrequencyRamp.getValue();
        _private->_lpf180->res = _private->resonanceRamp.getValue();
        _private->_lpf181->res = _private->resonanceRamp.getValue();

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
                continue;
            }

            if (channel == 0) {
                sp_lpf18_compute(_sp, _private->_lpf180, in, out);
            } else {
                sp_lpf18_compute(_sp, _private->_lpf181, in, out);
            }
        }
    }
}
