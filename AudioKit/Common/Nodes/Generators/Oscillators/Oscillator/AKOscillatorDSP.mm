//
//  AKOscillatorDSP.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#include "AKOscillatorDSP.hpp"
#import "AKLinearParameterRamp.hpp"

extern "C" AKDSPRef createOscillatorDSP(int nChannels, double sampleRate) {
    AKOscillatorDSP *dsp = new AKOscillatorDSP();
    dsp->init(nChannels, sampleRate);
    return dsp;
}

struct AKOscillatorDSP::InternalData {
    sp_osc *osc;
    sp_ftbl *ftbl;
    UInt32 ftbl_size = 4096;
    AKLinearParameterRamp frequencyRamp;
    AKLinearParameterRamp amplitudeRamp;
    AKLinearParameterRamp detuningOffsetRamp;
    AKLinearParameterRamp detuningMultiplierRamp;
};

AKOscillatorDSP::AKOscillatorDSP() : data(new InternalData) {
    data->frequencyRamp.setTarget(defaultFrequency, true);
    data->frequencyRamp.setDurationInSamples(defaultRampDurationSamples);
    data->amplitudeRamp.setTarget(defaultAmplitude, true);
    data->amplitudeRamp.setDurationInSamples(defaultRampDurationSamples);
    data->detuningOffsetRamp.setTarget(defaultDetuningOffset, true);
    data->detuningOffsetRamp.setDurationInSamples(defaultRampDurationSamples);
    data->detuningMultiplierRamp.setTarget(defaultDetuningMultiplier, true);
    data->detuningMultiplierRamp.setDurationInSamples(defaultRampDurationSamples);
}

// Uses the ParameterAddress as a key
void AKOscillatorDSP::setParameter(AUParameterAddress address, AUValue value, bool immediate) {
    switch (address) {
        case AKOscillatorParameterFrequency:
            data->frequencyRamp.setTarget(clamp(value, frequencyLowerBound, frequencyUpperBound), immediate);
            break;
        case AKOscillatorParameterAmplitude:
            data->amplitudeRamp.setTarget(clamp(value, amplitudeLowerBound, amplitudeUpperBound), immediate);
            break;
        case AKOscillatorParameterDetuningOffset:
            data->detuningOffsetRamp.setTarget(clamp(value, detuningOffsetLowerBound, detuningOffsetUpperBound), immediate);
            break;
        case AKOscillatorParameterDetuningMultiplier:
            data->detuningMultiplierRamp.setTarget(clamp(value, detuningMultiplierLowerBound, detuningMultiplierUpperBound), immediate);
            break;
        case AKOscillatorParameterRampDuration:
            data->frequencyRamp.setRampDuration(value, _sampleRate);
            data->amplitudeRamp.setRampDuration(value, _sampleRate);
            data->detuningOffsetRamp.setRampDuration(value, _sampleRate);
            data->detuningMultiplierRamp.setRampDuration(value, _sampleRate);
            break;
    }
}

// Uses the ParameterAddress as a key
float AKOscillatorDSP::getParameter(uint64_t address) {
    switch (address) {
        case AKOscillatorParameterFrequency:
            return data->frequencyRamp.getTarget();
        case AKOscillatorParameterAmplitude:
            return data->amplitudeRamp.getTarget();
        case AKOscillatorParameterDetuningOffset:
            return data->detuningOffsetRamp.getTarget();
        case AKOscillatorParameterDetuningMultiplier:
            return data->detuningMultiplierRamp.getTarget();
        case AKOscillatorParameterRampDuration:
            return data->frequencyRamp.getRampDuration(_sampleRate);
    }
    return 0;
}

void AKOscillatorDSP::init(int _channels, double _sampleRate) {
    AKSoundpipeDSPBase::init(_channels, _sampleRate);
    _playing = false;
    sp_osc_create(&data->osc);
    sp_osc_init(sp, data->osc, data->ftbl, 0);
    data->osc->freq = defaultFrequency;
    data->osc->amp = defaultAmplitude;
}

void AKOscillatorDSP::deinit() {
    sp_osc_destroy(&data->osc);
}

void AKOscillatorDSP::setupWaveform(uint32_t size) {
    data->ftbl_size = size;
    sp_ftbl_create(sp, &data->ftbl, data->ftbl_size);
}

void AKOscillatorDSP::setWaveformValue(uint32_t index, float value) {
    data->ftbl->tbl[index] = value;
}

void AKOscillatorDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);

        // do ramping every 8 samples
        if ((frameOffset & 0x7) == 0) {
            data->frequencyRamp.advanceTo(_now + frameOffset);
            data->amplitudeRamp.advanceTo(_now + frameOffset);
            data->detuningOffsetRamp.advanceTo(_now + frameOffset);
            data->detuningMultiplierRamp.advanceTo(_now + frameOffset);
        }
        data->osc->freq = data->frequencyRamp.getValue() * data->detuningMultiplierRamp.getValue() + data->detuningOffsetRamp.getValue();
        data->osc->amp = data->amplitudeRamp.getValue();

        float temp = 0;
        for (int channel = 0; channel < _nChannels; ++channel) {
            float *out = (float *)_outBufferListPtr->mBuffers[channel].mData + frameOffset;

            if (_playing) {
                if (channel == 0) {
                    sp_osc_compute(sp, data->osc, nil, &temp);
                }
                *out = temp;
            } else {
                *out = 0.0;
            }
        }
    }
}
