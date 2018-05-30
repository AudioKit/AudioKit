//
//  AKMoogLadderDSP.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#include "AKMoogLadderDSP.hpp"
#import "AKLinearParameterRamp.hpp"

extern "C" void* createMoogLadderDSP(int nChannels, double sampleRate) {
    AKMoogLadderDSP* dsp = new AKMoogLadderDSP();
    dsp->init(nChannels, sampleRate);
    return dsp;
}

struct AKMoogLadderDSP::_Internal {
    sp_moogladder *_moogladder0;
    sp_moogladder *_moogladder1;
    AKLinearParameterRamp cutoffFrequencyRamp;
    AKLinearParameterRamp resonanceRamp;
};

AKMoogLadderDSP::AKMoogLadderDSP() : _private(new _Internal) {
    _private->cutoffFrequencyRamp.setTarget(defaultCutoffFrequency, true);
    _private->cutoffFrequencyRamp.setDurationInSamples(defaultRampDurationSamples);
    _private->resonanceRamp.setTarget(defaultResonance, true);
    _private->resonanceRamp.setDurationInSamples(defaultRampDurationSamples);
}

// Uses the ParameterAddress as a key
void AKMoogLadderDSP::setParameter(AUParameterAddress address, AUValue value, bool immediate) {
    switch (address) {
        case AKMoogLadderParameterCutoffFrequency:
            _private->cutoffFrequencyRamp.setTarget(clamp(value, cutoffFrequencyLowerBound, cutoffFrequencyUpperBound), immediate);
            break;
        case AKMoogLadderParameterResonance:
            _private->resonanceRamp.setTarget(clamp(value, resonanceLowerBound, resonanceUpperBound), immediate);
            break;
        case AKMoogLadderParameterRampDuration:
            _private->cutoffFrequencyRamp.setRampDuration(value, _sampleRate);
            _private->resonanceRamp.setRampDuration(value, _sampleRate);
            break;
    }
}

// Uses the ParameterAddress as a key
float AKMoogLadderDSP::getParameter(uint64_t address) {
    switch (address) {
        case AKMoogLadderParameterCutoffFrequency:
            return _private->cutoffFrequencyRamp.getTarget();
        case AKMoogLadderParameterResonance:
            return _private->resonanceRamp.getTarget();
        case AKMoogLadderParameterRampDuration:
            return _private->cutoffFrequencyRamp.getRampDuration(_sampleRate);
    }
    return 0;
}

void AKMoogLadderDSP::init(int _channels, double _sampleRate) {
    AKSoundpipeDSPBase::init(_channels, _sampleRate);
    sp_moogladder_create(&_private->_moogladder0);
    sp_moogladder_init(_sp, _private->_moogladder0);
    sp_moogladder_create(&_private->_moogladder1);
    sp_moogladder_init(_sp, _private->_moogladder1);
    _private->_moogladder0->freq = defaultCutoffFrequency;
    _private->_moogladder1->freq = defaultCutoffFrequency;
    _private->_moogladder0->res = defaultResonance;
    _private->_moogladder1->res = defaultResonance;
}

void AKMoogLadderDSP::destroy() {
    sp_moogladder_destroy(&_private->_moogladder0);
    sp_moogladder_destroy(&_private->_moogladder1);
    AKSoundpipeDSPBase::destroy();
}

void AKMoogLadderDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);

        // do ramping every 8 samples
        if ((frameOffset & 0x7) == 0) {
            _private->cutoffFrequencyRamp.advanceTo(_now + frameOffset);
            _private->resonanceRamp.advanceTo(_now + frameOffset);
        }

        _private->_moogladder0->freq = _private->cutoffFrequencyRamp.getValue();
        _private->_moogladder1->freq = _private->cutoffFrequencyRamp.getValue();
        _private->_moogladder0->res = _private->resonanceRamp.getValue();
        _private->_moogladder1->res = _private->resonanceRamp.getValue();

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
                sp_moogladder_compute(_sp, _private->_moogladder0, in, out);
            } else {
                sp_moogladder_compute(_sp, _private->_moogladder1, in, out);
            }
        }
    }
}
