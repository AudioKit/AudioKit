// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "AKAmplitudeEnvelopeDSP.hpp"
#include "ParameterRamper.hpp"

extern "C" AKDSPRef createAmplitudeEnvelopeDSP() {
    return new AKAmplitudeEnvelopeDSP();
}

struct AKAmplitudeEnvelopeDSP::InternalData {
    sp_adsr *adsr;
    float internalGate = 0;
    float amp = 0;
    ParameterRamper attackDurationRamp;
    ParameterRamper decayDurationRamp;
    ParameterRamper sustainLevelRamp;
    ParameterRamper releaseDurationRamp;
};

AKAmplitudeEnvelopeDSP::AKAmplitudeEnvelopeDSP() : data(new InternalData) {
    parameters[AKAmplitudeEnvelopeParameterAttackDuration] = &data->attackDurationRamp;
    parameters[AKAmplitudeEnvelopeParameterDecayDuration] = &data->decayDurationRamp;
    parameters[AKAmplitudeEnvelopeParameterSustainLevel] = &data->sustainLevelRamp;
    parameters[AKAmplitudeEnvelopeParameterReleaseDuration] = &data->releaseDurationRamp;
}

void AKAmplitudeEnvelopeDSP::init(int channelCount, double sampleRate) {
    AKSoundpipeDSPBase::init(channelCount, sampleRate);
    sp_adsr_create(&data->adsr);
    sp_adsr_init(sp, data->adsr);
}

void AKAmplitudeEnvelopeDSP::deinit() {
    AKSoundpipeDSPBase::deinit();
    sp_adsr_destroy(&data->adsr);
}

void AKAmplitudeEnvelopeDSP::reset() {
    AKSoundpipeDSPBase::reset();
    if (!isInitialized) return;
    sp_adsr_init(sp, data->adsr);
}

void AKAmplitudeEnvelopeDSP::start() {
    AKSoundpipeDSPBase::start();
    data->internalGate = 1;
}

void AKAmplitudeEnvelopeDSP::stop() {
    AKSoundpipeDSPBase::stop();
    data->internalGate = 0;
}

void AKAmplitudeEnvelopeDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);

        data->adsr->atk = data->attackDurationRamp.getAndStep();
        data->adsr->dec = data->decayDurationRamp.getAndStep();
        data->adsr->sus = data->sustainLevelRamp.getAndStep();
        data->adsr->rel = data->releaseDurationRamp.getAndStep();

        sp_adsr_compute(sp, data->adsr, &data->internalGate, &data->amp);

        for (int channel = 0; channel < channelCount; ++channel) {
            float *in  = (float *)inputBufferLists[0]->mBuffers[channel].mData  + frameOffset;
            float *out = (float *)outputBufferLists[0]->mBuffers[channel].mData + frameOffset;
            *out = *in * data->amp;
        }
    }
}
