// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "AKDripDSP.hpp"
#include "ParameterRamper.hpp"

extern "C" AKDSPRef createDripDSP() {
    return new AKDripDSP();
}

struct AKDripDSP::InternalData {
    sp_drip *drip;
    float internalTrigger = 0;
    ParameterRamper intensityRamp;
    ParameterRamper dampingFactorRamp;
    ParameterRamper energyReturnRamp;
    ParameterRamper mainResonantFrequencyRamp;
    ParameterRamper firstResonantFrequencyRamp;
    ParameterRamper secondResonantFrequencyRamp;
    ParameterRamper amplitudeRamp;
};

AKDripDSP::AKDripDSP() : data(new InternalData) {
    parameters[AKDripParameterIntensity] = &data->intensityRamp;
    parameters[AKDripParameterDampingFactor] = &data->dampingFactorRamp;
    parameters[AKDripParameterEnergyReturn] = &data->energyReturnRamp;
    parameters[AKDripParameterMainResonantFrequency] = &data->mainResonantFrequencyRamp;
    parameters[AKDripParameterFirstResonantFrequency] = &data->firstResonantFrequencyRamp;
    parameters[AKDripParameterSecondResonantFrequency] = &data->secondResonantFrequencyRamp;
    parameters[AKDripParameterAmplitude] = &data->amplitudeRamp;
}

void AKDripDSP::init(int channelCount, double sampleRate) {
    AKSoundpipeDSPBase::init(channelCount, sampleRate);
    sp_drip_create(&data->drip);
    sp_drip_init(sp, data->drip, 0.9);
}

void AKDripDSP::deinit() {
    AKSoundpipeDSPBase::deinit();
    sp_drip_destroy(&data->drip);
}

void AKDripDSP::reset() {
    AKSoundpipeDSPBase::reset();
    if (!isInitialized) return;
    sp_drip_init(sp, data->drip, 0.9);
}

void AKDripDSP::trigger() {
    data->internalTrigger = 1;
}

void AKDripDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {
    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);

        data->drip->num_tubes = data->intensityRamp.getAndStep();
        data->drip->damp = data->dampingFactorRamp.getAndStep();
        data->drip->shake_max = data->energyReturnRamp.getAndStep();
        data->drip->freq = data->mainResonantFrequencyRamp.getAndStep();
        data->drip->freq1 = data->firstResonantFrequencyRamp.getAndStep();
        data->drip->freq2 = data->secondResonantFrequencyRamp.getAndStep();
        data->drip->amp = data->amplitudeRamp.getAndStep();

        float temp = 0;
        for (int channel = 0; channel < channelCount; ++channel) {
            float *out = (float *)outputBufferLists[0]->mBuffers[channel].mData + frameOffset;

            if (isStarted) {
                if (channel == 0) {
                    sp_drip_compute(sp, data->drip, &data->internalTrigger, &temp);
                    data->internalTrigger = 0.0;
                }
                *out = temp;
            } else {
                *out = 0.0;
            }
        }
    }
}
