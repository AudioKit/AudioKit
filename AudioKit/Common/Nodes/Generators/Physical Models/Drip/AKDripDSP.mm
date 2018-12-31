//
//  AKDripDSP.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#include "AKDripDSP.hpp"
#import "AKLinearParameterRamp.hpp"

extern "C" AKDSPRef createDripDSP(int channelCount, double sampleRate) {
    AKDripDSP *dsp = new AKDripDSP();
    dsp->init(channelCount, sampleRate);
    return dsp;
}

struct AKDripDSP::InternalData {
    sp_drip *drip;
    AKLinearParameterRamp intensityRamp;
    AKLinearParameterRamp dampingFactorRamp;
    AKLinearParameterRamp energyReturnRamp;
    AKLinearParameterRamp mainResonantFrequencyRamp;
    AKLinearParameterRamp firstResonantFrequencyRamp;
    AKLinearParameterRamp secondResonantFrequencyRamp;
    AKLinearParameterRamp amplitudeRamp;
};

AKDripDSP::AKDripDSP() : data(new InternalData) {
    data->intensityRamp.setTarget(defaultIntensity, true);
    data->intensityRamp.setDurationInSamples(defaultRampDurationSamples);
    data->dampingFactorRamp.setTarget(defaultDampingFactor, true);
    data->dampingFactorRamp.setDurationInSamples(defaultRampDurationSamples);
    data->energyReturnRamp.setTarget(defaultEnergyReturn, true);
    data->energyReturnRamp.setDurationInSamples(defaultRampDurationSamples);
    data->mainResonantFrequencyRamp.setTarget(defaultMainResonantFrequency, true);
    data->mainResonantFrequencyRamp.setDurationInSamples(defaultRampDurationSamples);
    data->firstResonantFrequencyRamp.setTarget(defaultFirstResonantFrequency, true);
    data->firstResonantFrequencyRamp.setDurationInSamples(defaultRampDurationSamples);
    data->secondResonantFrequencyRamp.setTarget(defaultSecondResonantFrequency, true);
    data->secondResonantFrequencyRamp.setDurationInSamples(defaultRampDurationSamples);
    data->amplitudeRamp.setTarget(defaultAmplitude, true);
    data->amplitudeRamp.setDurationInSamples(defaultRampDurationSamples);
}

// Uses the ParameterAddress as a key
void AKDripDSP::setParameter(AUParameterAddress address, AUValue value, bool immediate) {
    switch (address) {
        case AKDripParameterIntensity:
            data->intensityRamp.setTarget(clamp(value, intensityLowerBound, intensityUpperBound), immediate);
            break;
        case AKDripParameterDampingFactor:
            data->dampingFactorRamp.setTarget(clamp(value, dampingFactorLowerBound, dampingFactorUpperBound), immediate);
            break;
        case AKDripParameterEnergyReturn:
            data->energyReturnRamp.setTarget(clamp(value, energyReturnLowerBound, energyReturnUpperBound), immediate);
            break;
        case AKDripParameterMainResonantFrequency:
            data->mainResonantFrequencyRamp.setTarget(clamp(value, mainResonantFrequencyLowerBound, mainResonantFrequencyUpperBound), immediate);
            break;
        case AKDripParameterFirstResonantFrequency:
            data->firstResonantFrequencyRamp.setTarget(clamp(value, firstResonantFrequencyLowerBound, firstResonantFrequencyUpperBound), immediate);
            break;
        case AKDripParameterSecondResonantFrequency:
            data->secondResonantFrequencyRamp.setTarget(clamp(value, secondResonantFrequencyLowerBound, secondResonantFrequencyUpperBound), immediate);
            break;
        case AKDripParameterAmplitude:
            data->amplitudeRamp.setTarget(clamp(value, amplitudeLowerBound, amplitudeUpperBound), immediate);
            break;
        case AKDripParameterRampDuration:
            data->intensityRamp.setRampDuration(value, sampleRate);
            data->dampingFactorRamp.setRampDuration(value, sampleRate);
            data->energyReturnRamp.setRampDuration(value, sampleRate);
            data->mainResonantFrequencyRamp.setRampDuration(value, sampleRate);
            data->firstResonantFrequencyRamp.setRampDuration(value, sampleRate);
            data->secondResonantFrequencyRamp.setRampDuration(value, sampleRate);
            data->amplitudeRamp.setRampDuration(value, sampleRate);
            break;
    }
}

// Uses the ParameterAddress as a key
float AKDripDSP::getParameter(uint64_t address) {
    switch (address) {
        case AKDripParameterIntensity:
            return data->intensityRamp.getTarget();
        case AKDripParameterDampingFactor:
            return data->dampingFactorRamp.getTarget();
        case AKDripParameterEnergyReturn:
            return data->energyReturnRamp.getTarget();
        case AKDripParameterMainResonantFrequency:
            return data->mainResonantFrequencyRamp.getTarget();
        case AKDripParameterFirstResonantFrequency:
            return data->firstResonantFrequencyRamp.getTarget();
        case AKDripParameterSecondResonantFrequency:
            return data->secondResonantFrequencyRamp.getTarget();
        case AKDripParameterAmplitude:
            return data->amplitudeRamp.getTarget();
        case AKDripParameterRampDuration:
            return data->intensityRamp.getRampDuration(sampleRate);
    }
    return 0;
}

void AKDripDSP::init(int channelCount, double sampleRate) {
    AKSoundpipeDSPBase::init(channelCount, sampleRate);
    sp_drip_create(&data->drip);
    sp_drip_init(sp, data->drip, 0.9);
    data->drip->num_tubes = defaultIntensity;
    data->drip->damp = defaultDampingFactor;
    data->drip->shake_max = defaultEnergyReturn;
    data->drip->freq = defaultMainResonantFrequency;
    data->drip->freq1 = defaultFirstResonantFrequency;
    data->drip->freq2 = defaultSecondResonantFrequency;
    data->drip->amp = defaultAmplitude;
}

void AKDripDSP::deinit() {
    sp_drip_destroy(&data->drip);
}

void AKDripDSP::trigger() {
    internalTrigger = 1;
}

void AKDripDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);

        // do ramping every 8 samples
        if ((frameOffset & 0x7) == 0) {
            data->intensityRamp.advanceTo(now + frameOffset);
            data->dampingFactorRamp.advanceTo(now + frameOffset);
            data->energyReturnRamp.advanceTo(now + frameOffset);
            data->mainResonantFrequencyRamp.advanceTo(now + frameOffset);
            data->firstResonantFrequencyRamp.advanceTo(now + frameOffset);
            data->secondResonantFrequencyRamp.advanceTo(now + frameOffset);
            data->amplitudeRamp.advanceTo(now + frameOffset);
        }

        data->drip->num_tubes = data->intensityRamp.getValue();
        data->drip->damp = data->dampingFactorRamp.getValue();
        data->drip->shake_max = data->energyReturnRamp.getValue();
        data->drip->freq = data->mainResonantFrequencyRamp.getValue();
        data->drip->freq1 = data->firstResonantFrequencyRamp.getValue();
        data->drip->freq2 = data->secondResonantFrequencyRamp.getValue();
        data->drip->amp = data->amplitudeRamp.getValue();

        float temp = 0;
        for (int channel = 0; channel < channelCount; ++channel) {
            float *out = (float *)outBufferListPtr->mBuffers[channel].mData + frameOffset;

            if (isStarted) {
                if (channel == 0) {
                    sp_drip_compute(sp, data->drip, &internalTrigger, &temp);
                    internalTrigger = 0.0;
                }
                *out = temp;
            } else {
                *out = 0.0;
            }
        }
    }
}
