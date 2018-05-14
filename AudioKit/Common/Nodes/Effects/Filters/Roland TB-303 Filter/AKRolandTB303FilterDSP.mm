//
//  AKRolandTB303FilterDSP.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#include "AKRolandTB303FilterDSP.hpp"
#import "AKLinearParameterRamp.hpp"

extern "C" void* createRolandTB303FilterDSP(int nChannels, double sampleRate) {
    AKRolandTB303FilterDSP* dsp = new AKRolandTB303FilterDSP();
    dsp->init(nChannels, sampleRate);
    return dsp;
}

struct AKRolandTB303FilterDSP::_Internal {
    sp_tbvcf *_tbvcf0;
    sp_tbvcf *_tbvcf1;
    AKLinearParameterRamp cutoffFrequencyRamp;
    AKLinearParameterRamp resonanceRamp;
    AKLinearParameterRamp distortionRamp;
    AKLinearParameterRamp resonanceAsymmetryRamp;
};

AKRolandTB303FilterDSP::AKRolandTB303FilterDSP() : _private(new _Internal) {
    _private->cutoffFrequencyRamp.setTarget(defaultCutoffFrequency, true);
    _private->cutoffFrequencyRamp.setDurationInSamples(defaultRampDurationSamples);
    _private->resonanceRamp.setTarget(defaultResonance, true);
    _private->resonanceRamp.setDurationInSamples(defaultRampDurationSamples);
    _private->distortionRamp.setTarget(defaultDistortion, true);
    _private->distortionRamp.setDurationInSamples(defaultRampDurationSamples);
    _private->resonanceAsymmetryRamp.setTarget(defaultResonanceAsymmetry, true);
    _private->resonanceAsymmetryRamp.setDurationInSamples(defaultRampDurationSamples);
}

// Uses the ParameterAddress as a key
void AKRolandTB303FilterDSP::setParameter(AUParameterAddress address, AUValue value, bool immediate) {
    switch (address) {
        case AKRolandTB303FilterParameterCutoffFrequency:
            _private->cutoffFrequencyRamp.setTarget(clamp(value, cutoffFrequencyLowerBound, cutoffFrequencyUpperBound), immediate);
            break;
        case AKRolandTB303FilterParameterResonance:
            _private->resonanceRamp.setTarget(clamp(value, resonanceLowerBound, resonanceUpperBound), immediate);
            break;
        case AKRolandTB303FilterParameterDistortion:
            _private->distortionRamp.setTarget(clamp(value, distortionLowerBound, distortionUpperBound), immediate);
            break;
        case AKRolandTB303FilterParameterResonanceAsymmetry:
            _private->resonanceAsymmetryRamp.setTarget(clamp(value, resonanceAsymmetryLowerBound, resonanceAsymmetryUpperBound), immediate);
            break;
        case AKRolandTB303FilterParameterRampDuration:
            _private->cutoffFrequencyRamp.setRampDuration(value, _sampleRate);
            _private->resonanceRamp.setRampDuration(value, _sampleRate);
            _private->distortionRamp.setRampDuration(value, _sampleRate);
            _private->resonanceAsymmetryRamp.setRampDuration(value, _sampleRate);
            break;
    }
}

// Uses the ParameterAddress as a key
float AKRolandTB303FilterDSP::getParameter(uint64_t address) {
    switch (address) {
        case AKRolandTB303FilterParameterCutoffFrequency:
            return _private->cutoffFrequencyRamp.getTarget();
        case AKRolandTB303FilterParameterResonance:
            return _private->resonanceRamp.getTarget();
        case AKRolandTB303FilterParameterDistortion:
            return _private->distortionRamp.getTarget();
        case AKRolandTB303FilterParameterResonanceAsymmetry:
            return _private->resonanceAsymmetryRamp.getTarget();
        case AKRolandTB303FilterParameterRampDuration:
            return _private->cutoffFrequencyRamp.getRampDuration(_sampleRate);
    }
    return 0;
}

void AKRolandTB303FilterDSP::init(int _channels, double _sampleRate) {
    AKSoundpipeDSPBase::init(_channels, _sampleRate);
    sp_tbvcf_create(&_private->_tbvcf0);
    sp_tbvcf_init(_sp, _private->_tbvcf0);
    sp_tbvcf_create(&_private->_tbvcf1);
    sp_tbvcf_init(_sp, _private->_tbvcf1);
    _private->_tbvcf0->fco = defaultCutoffFrequency;
    _private->_tbvcf1->fco = defaultCutoffFrequency;
    _private->_tbvcf0->res = defaultResonance;
    _private->_tbvcf1->res = defaultResonance;
    _private->_tbvcf0->dist = defaultDistortion;
    _private->_tbvcf1->dist = defaultDistortion;
    _private->_tbvcf0->asym = defaultResonanceAsymmetry;
    _private->_tbvcf1->asym = defaultResonanceAsymmetry;
}

void AKRolandTB303FilterDSP::destroy() {
    sp_tbvcf_destroy(&_private->_tbvcf0);
    sp_tbvcf_destroy(&_private->_tbvcf1);
    AKSoundpipeDSPBase::destroy();
}

void AKRolandTB303FilterDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);

        // do ramping every 8 samples
        if ((frameOffset & 0x7) == 0) {
            _private->cutoffFrequencyRamp.advanceTo(_now + frameOffset);
            _private->resonanceRamp.advanceTo(_now + frameOffset);
            _private->distortionRamp.advanceTo(_now + frameOffset);
            _private->resonanceAsymmetryRamp.advanceTo(_now + frameOffset);
        }

        _private->_tbvcf0->fco = _private->cutoffFrequencyRamp.getValue();
        _private->_tbvcf1->fco = _private->cutoffFrequencyRamp.getValue();
        _private->_tbvcf0->res = _private->resonanceRamp.getValue();
        _private->_tbvcf1->res = _private->resonanceRamp.getValue();
        _private->_tbvcf0->dist = _private->distortionRamp.getValue();
        _private->_tbvcf1->dist = _private->distortionRamp.getValue();
        _private->_tbvcf0->asym = _private->resonanceAsymmetryRamp.getValue();
        _private->_tbvcf1->asym = _private->resonanceAsymmetryRamp.getValue();

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
                sp_tbvcf_compute(_sp, _private->_tbvcf0, in, out);
            } else {
                sp_tbvcf_compute(_sp, _private->_tbvcf1, in, out);
            }
        }
    }
}
