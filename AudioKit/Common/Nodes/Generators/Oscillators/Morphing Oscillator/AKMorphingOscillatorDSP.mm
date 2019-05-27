//
//  AKMorphingOscillatorDSP.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#include "AKMorphingOscillatorDSP.hpp"
#import "AKLinearParameterRamp.hpp"

extern "C" AKDSPRef createMorphingOscillatorDSP(int channelCount, double sampleRate) {
    AKMorphingOscillatorDSP *dsp = new AKMorphingOscillatorDSP();
    dsp->init(channelCount, sampleRate);
    return dsp;
}

struct AKMorphingOscillatorDSP::InternalData {
    sp_oscmorph *oscmorph;
    sp_ftbl *ft_array[4];
    UInt32 ftbl_size = 4096;
    AKLinearParameterRamp frequencyRamp;
    AKLinearParameterRamp amplitudeRamp;
    AKLinearParameterRamp indexRamp;
    AKLinearParameterRamp detuningOffsetRamp;
    AKLinearParameterRamp detuningMultiplierRamp;
};

AKMorphingOscillatorDSP::AKMorphingOscillatorDSP() : data(new InternalData) {
    data->frequencyRamp.setTarget(defaultFrequency, true);
    data->frequencyRamp.setDurationInSamples(defaultRampDurationSamples);
    data->amplitudeRamp.setTarget(defaultAmplitude, true);
    data->amplitudeRamp.setDurationInSamples(defaultRampDurationSamples);
    data->indexRamp.setTarget(defaultIndex, true);
    data->indexRamp.setDurationInSamples(defaultRampDurationSamples);
    data->detuningOffsetRamp.setTarget(defaultDetuningOffset, true);
    data->detuningOffsetRamp.setDurationInSamples(defaultRampDurationSamples);
    data->detuningMultiplierRamp.setTarget(defaultDetuningMultiplier, true);
    data->detuningMultiplierRamp.setDurationInSamples(defaultRampDurationSamples);
}

// Uses the ParameterAddress as a key
void AKMorphingOscillatorDSP::setParameter(AUParameterAddress address, AUValue value, bool immediate) {
    switch (address) {
        case AKMorphingOscillatorParameterFrequency:
            data->frequencyRamp.setTarget(clamp(value, frequencyLowerBound, frequencyUpperBound), immediate);
            break;
        case AKMorphingOscillatorParameterAmplitude:
            data->amplitudeRamp.setTarget(clamp(value, amplitudeLowerBound, amplitudeUpperBound), immediate);
            break;
        case AKMorphingOscillatorParameterIndex:
            data->indexRamp.setTarget(clamp(value, indexLowerBound, indexUpperBound), immediate);
            break;
        case AKMorphingOscillatorParameterDetuningOffset:
            data->detuningOffsetRamp.setTarget(clamp(value, detuningOffsetLowerBound, detuningOffsetUpperBound), immediate);
            break;
        case AKMorphingOscillatorParameterDetuningMultiplier:
            data->detuningMultiplierRamp.setTarget(clamp(value, detuningMultiplierLowerBound, detuningMultiplierUpperBound), immediate);
            break;
        case AKMorphingOscillatorParameterRampDuration:
            data->frequencyRamp.setRampDuration(value, sampleRate);
            data->amplitudeRamp.setRampDuration(value, sampleRate);
            data->indexRamp.setRampDuration(value, sampleRate);
            data->detuningOffsetRamp.setRampDuration(value, sampleRate);
            data->detuningMultiplierRamp.setRampDuration(value, sampleRate);
            break;
    }
}

// Uses the ParameterAddress as a key
float AKMorphingOscillatorDSP::getParameter(uint64_t address) {
    switch (address) {
        case AKMorphingOscillatorParameterFrequency:
            return data->frequencyRamp.getTarget();
        case AKMorphingOscillatorParameterAmplitude:
            return data->amplitudeRamp.getTarget();
        case AKMorphingOscillatorParameterIndex:
            return data->indexRamp.getTarget();
        case AKMorphingOscillatorParameterDetuningOffset:
            return data->detuningOffsetRamp.getTarget();
        case AKMorphingOscillatorParameterDetuningMultiplier:
            return data->detuningMultiplierRamp.getTarget();
        case AKMorphingOscillatorParameterRampDuration:
            return data->frequencyRamp.getRampDuration(sampleRate);
    }
    return 0;
}

void AKMorphingOscillatorDSP::init(int channelCount, double sampleRate) {
    AKSoundpipeDSPBase::init(channelCount, sampleRate);
    isStarted = false;
    sp_oscmorph_create(&data->oscmorph);
}

void AKMorphingOscillatorDSP::deinit() {
    sp_oscmorph_destroy(&data->oscmorph);
}

void  AKMorphingOscillatorDSP::reset() {
    sp_oscmorph_init(sp, data->oscmorph, data->ft_array, 4, 0);
    data->oscmorph->freq = defaultFrequency;
    data->oscmorph->amp = defaultAmplitude;
    data->oscmorph->wtpos = defaultIndex;
    AKSoundpipeDSPBase::reset();
}

void AKMorphingOscillatorDSP::setupIndividualWaveform(uint32_t waveform, uint32_t size) {
    data->ftbl_size = size;
    sp_ftbl_create(sp, &data->ft_array[waveform], data->ftbl_size);
}

void AKMorphingOscillatorDSP::setIndividualWaveformValue(uint32_t waveform, uint32_t index, float value) {
    data->ft_array[waveform]->tbl[index] = value;
}
void AKMorphingOscillatorDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);

        // do ramping every 8 samples
        if ((frameOffset & 0x7) == 0) {
            data->frequencyRamp.advanceTo(now + frameOffset);
            data->amplitudeRamp.advanceTo(now + frameOffset);
            data->indexRamp.advanceTo(now + frameOffset);
            data->detuningOffsetRamp.advanceTo(now + frameOffset);
            data->detuningMultiplierRamp.advanceTo(now + frameOffset);
        }

        data->oscmorph->freq = data->frequencyRamp.getValue() * data->detuningMultiplierRamp.getValue() + data->detuningOffsetRamp.getValue();
        data->oscmorph->amp = data->amplitudeRamp.getValue();
        data->oscmorph->wtpos = data->indexRamp.getValue();

        float temp = 0;
        for (int channel = 0; channel < channelCount; ++channel) {
            float *out = (float *)outBufferListPtr->mBuffers[channel].mData + frameOffset;

            if (isStarted) {
                if (channel == 0) {
                    sp_oscmorph_compute(sp, data->oscmorph, nil, &temp);
                }
                *out = temp;
            } else {
                *out = 0.0;
            }
        }
    }
}
