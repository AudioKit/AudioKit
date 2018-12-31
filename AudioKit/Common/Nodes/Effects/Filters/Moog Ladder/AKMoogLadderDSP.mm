//
//  AKMoogLadderDSP.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#include "AKMoogLadderDSP.hpp"
#import "AKLinearParameterRamp.hpp"

extern "C" AKDSPRef createMoogLadderDSP(int nChannels, double sampleRate) {
    AKMoogLadderDSP *dsp = new AKMoogLadderDSP();
    dsp->init(nChannels, sampleRate);
    return dsp;
}

struct AKMoogLadderDSP::_Internal {
    sp_moogladder *_moogladder0;
    sp_moogladder *_moogladder1;
    AKLinearParameterRamp cutoffFrequencyRamp;
    AKLinearParameterRamp resonanceRamp;
};

AKMoogLadderDSP::AKMoogLadderDSP() : data(new _Internal) {
    data->cutoffFrequencyRamp.setTarget(defaultCutoffFrequency, true);
    data->cutoffFrequencyRamp.setDurationInSamples(defaultRampDurationSamples);
    data->resonanceRamp.setTarget(defaultResonance, true);
    data->resonanceRamp.setDurationInSamples(defaultRampDurationSamples);
}

// Uses the ParameterAddress as a key
void AKMoogLadderDSP::setParameter(AUParameterAddress address, AUValue value, bool immediate) {
    switch (address) {
        case AKMoogLadderParameterCutoffFrequency:
            data->cutoffFrequencyRamp.setTarget(clamp(value, cutoffFrequencyLowerBound, cutoffFrequencyUpperBound), immediate);
            break;
        case AKMoogLadderParameterResonance:
            data->resonanceRamp.setTarget(clamp(value, resonanceLowerBound, resonanceUpperBound), immediate);
            break;
        case AKMoogLadderParameterRampDuration:
            data->cutoffFrequencyRamp.setRampDuration(value, _sampleRate);
            data->resonanceRamp.setRampDuration(value, _sampleRate);
            break;
    }
}

// Uses the ParameterAddress as a key
float AKMoogLadderDSP::getParameter(uint64_t address) {
    switch (address) {
        case AKMoogLadderParameterCutoffFrequency:
            return data->cutoffFrequencyRamp.getTarget();
        case AKMoogLadderParameterResonance:
            return data->resonanceRamp.getTarget();
        case AKMoogLadderParameterRampDuration:
            return data->cutoffFrequencyRamp.getRampDuration(_sampleRate);
    }
    return 0;
}

void AKMoogLadderDSP::init(int _channels, double _sampleRate) {
    AKSoundpipeDSPBase::init(_channels, _sampleRate);
    sp_moogladder_create(&data->_moogladder0);
    sp_moogladder_init(_sp, data->_moogladder0);
    sp_moogladder_create(&data->_moogladder1);
    sp_moogladder_init(_sp, data->_moogladder1);
    data->_moogladder0->freq = defaultCutoffFrequency;
    data->_moogladder1->freq = defaultCutoffFrequency;
    data->_moogladder0->res = defaultResonance;
    data->_moogladder1->res = defaultResonance;
}

void AKMoogLadderDSP::deinit() {
    sp_moogladder_destroy(&data->_moogladder0);
    sp_moogladder_destroy(&data->_moogladder1);
}

void AKMoogLadderDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);

        // do ramping every 8 samples
        if ((frameOffset & 0x7) == 0) {
            data->cutoffFrequencyRamp.advanceTo(_now + frameOffset);
            data->resonanceRamp.advanceTo(_now + frameOffset);
        }

        data->_moogladder0->freq = data->cutoffFrequencyRamp.getValue();
        data->_moogladder1->freq = data->cutoffFrequencyRamp.getValue();
        data->_moogladder0->res = data->resonanceRamp.getValue();
        data->_moogladder1->res = data->resonanceRamp.getValue();

        float *tmpin[2];
        float *tmpout[2];
        for (int channel = 0; channel < _nChannels; ++channel) {
            float *in  = (float *)_inBufferListPtr->mBuffers[channel].mData  + frameOffset;
            float *out = (float *)_outBufferListPtr->mBuffers[channel].mData + frameOffset;
            if (channel < 2) {
                tmpin[channel] = in;
                tmpout[channel] = out;
            }
            if (!_playing) {
                *out = *in;
                continue;
            }

            if (channel == 0) {
                sp_moogladder_compute(_sp, data->_moogladder0, in, out);
            } else {
                sp_moogladder_compute(_sp, data->_moogladder1, in, out);
            }
        }
    }
}
