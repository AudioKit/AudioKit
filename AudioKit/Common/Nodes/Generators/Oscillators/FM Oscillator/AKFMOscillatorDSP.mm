//
//  AKFMOscillatorDSP.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#include "AKFMOscillatorDSP.hpp"
#import "AKLinearParameterRamp.hpp"

extern "C" AKDSPRef createFMOscillatorDSP(int channelCount, double sampleRate) {
    AKFMOscillatorDSP *dsp = new AKFMOscillatorDSP();
    dsp->init(channelCount, sampleRate);
    return dsp;
}

struct AKFMOscillatorDSP::InternalData {
    sp_fosc *fosc;
    sp_ftbl *ftbl;
    UInt32 ftbl_size = 4096;
    AKLinearParameterRamp baseFrequencyRamp;
    AKLinearParameterRamp carrierMultiplierRamp;
    AKLinearParameterRamp modulatingMultiplierRamp;
    AKLinearParameterRamp modulationIndexRamp;
    AKLinearParameterRamp amplitudeRamp;
};

AKFMOscillatorDSP::AKFMOscillatorDSP() : data(new InternalData) {
    data->baseFrequencyRamp.setTarget(defaultBaseFrequency, true);
    data->baseFrequencyRamp.setDurationInSamples(defaultRampDurationSamples);
    data->carrierMultiplierRamp.setTarget(defaultCarrierMultiplier, true);
    data->carrierMultiplierRamp.setDurationInSamples(defaultRampDurationSamples);
    data->modulatingMultiplierRamp.setTarget(defaultModulatingMultiplier, true);
    data->modulatingMultiplierRamp.setDurationInSamples(defaultRampDurationSamples);
    data->modulationIndexRamp.setTarget(defaultModulationIndex, true);
    data->modulationIndexRamp.setDurationInSamples(defaultRampDurationSamples);
    data->amplitudeRamp.setTarget(defaultAmplitude, true);
    data->amplitudeRamp.setDurationInSamples(defaultRampDurationSamples);
}

// Uses the ParameterAddress as a key
void AKFMOscillatorDSP::setParameter(AUParameterAddress address, AUValue value, bool immediate) {
    switch (address) {
        case AKFMOscillatorParameterBaseFrequency:
            data->baseFrequencyRamp.setTarget(clamp(value, baseFrequencyLowerBound, baseFrequencyUpperBound), immediate);
            break;
        case AKFMOscillatorParameterCarrierMultiplier:
            data->carrierMultiplierRamp.setTarget(clamp(value, carrierMultiplierLowerBound, carrierMultiplierUpperBound), immediate);
            break;
        case AKFMOscillatorParameterModulatingMultiplier:
            data->modulatingMultiplierRamp.setTarget(clamp(value, modulatingMultiplierLowerBound, modulatingMultiplierUpperBound), immediate);
            break;
        case AKFMOscillatorParameterModulationIndex:
            data->modulationIndexRamp.setTarget(clamp(value, modulationIndexLowerBound, modulationIndexUpperBound), immediate);
            break;
        case AKFMOscillatorParameterAmplitude:
            data->amplitudeRamp.setTarget(clamp(value, amplitudeLowerBound, amplitudeUpperBound), immediate);
            break;
        case AKFMOscillatorParameterRampDuration:
            data->baseFrequencyRamp.setRampDuration(value, sampleRate);
            data->carrierMultiplierRamp.setRampDuration(value, sampleRate);
            data->modulatingMultiplierRamp.setRampDuration(value, sampleRate);
            data->modulationIndexRamp.setRampDuration(value, sampleRate);
            data->amplitudeRamp.setRampDuration(value, sampleRate);
            break;
    }
}

// Uses the ParameterAddress as a key
float AKFMOscillatorDSP::getParameter(uint64_t address) {
    switch (address) {
        case AKFMOscillatorParameterBaseFrequency:
            return data->baseFrequencyRamp.getTarget();
        case AKFMOscillatorParameterCarrierMultiplier:
            return data->carrierMultiplierRamp.getTarget();
        case AKFMOscillatorParameterModulatingMultiplier:
            return data->modulatingMultiplierRamp.getTarget();
        case AKFMOscillatorParameterModulationIndex:
            return data->modulationIndexRamp.getTarget();
        case AKFMOscillatorParameterAmplitude:
            return data->amplitudeRamp.getTarget();
        case AKFMOscillatorParameterRampDuration:
            return data->baseFrequencyRamp.getRampDuration(sampleRate);
    }
    return 0;
}

void AKFMOscillatorDSP::init(int channelCount, double sampleRate) {
    AKSoundpipeDSPBase::init(channelCount, sampleRate);
    isStarted = false;
    sp_fosc_create(&data->fosc);
    sp_fosc_init(sp, data->fosc, data->ftbl);
    data->fosc->freq = defaultBaseFrequency;
    data->fosc->car = defaultCarrierMultiplier;
    data->fosc->mod = defaultModulatingMultiplier;
    data->fosc->indx = defaultModulationIndex;
    data->fosc->amp = defaultAmplitude;
}

void AKFMOscillatorDSP::deinit() {
    sp_fosc_destroy(&data->fosc);
}

void AKFMOscillatorDSP::setupWaveform(uint32_t size) {
    data->ftbl_size = size;
    sp_ftbl_create(sp, &data->ftbl, data->ftbl_size);
}

void AKFMOscillatorDSP::setWaveformValue(uint32_t index, float value) {
    data->ftbl->tbl[index] = value;
}
void AKFMOscillatorDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);

        // do ramping every 8 samples
        if ((frameOffset & 0x7) == 0) {
            data->baseFrequencyRamp.advanceTo(now + frameOffset);
            data->carrierMultiplierRamp.advanceTo(now + frameOffset);
            data->modulatingMultiplierRamp.advanceTo(now + frameOffset);
            data->modulationIndexRamp.advanceTo(now + frameOffset);
            data->amplitudeRamp.advanceTo(now + frameOffset);
        }

        data->fosc->freq = data->baseFrequencyRamp.getValue();
        data->fosc->car = data->carrierMultiplierRamp.getValue();
        data->fosc->mod = data->modulatingMultiplierRamp.getValue();
        data->fosc->indx = data->modulationIndexRamp.getValue();
        data->fosc->amp = data->amplitudeRamp.getValue();

        float temp = 0;
        for (int channel = 0; channel < channelCount; ++channel) {
            float *out = (float *)outBufferListPtr->mBuffers[channel].mData + frameOffset;

            if (isStarted) {
                if (channel == 0) {
                    sp_fosc_compute(sp, data->fosc, nil, &temp);
                }
                *out = temp;
            } else {
                *out = 0.0;
            }
        }
    }
}
