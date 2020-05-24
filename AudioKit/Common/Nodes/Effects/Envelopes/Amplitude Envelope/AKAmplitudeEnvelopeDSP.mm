//
//  AKAmplitudeEnvelopeDSP.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2020 AudioKit. All rights reserved.
//

#include "AKAmplitudeEnvelopeDSP.hpp"
#include "AKLinearParameterRamp.hpp"

extern "C" AKDSPRef createAmplitudeEnvelopeDSP() {
    return new AKAmplitudeEnvelopeDSP();
}

struct AKAmplitudeEnvelopeDSP::InternalData {
    sp_adsr *adsr;
    float internalGate = 0;
    float amp = 0;
    AKLinearParameterRamp attackDurationRamp;
    AKLinearParameterRamp decayDurationRamp;
    AKLinearParameterRamp sustainLevelRamp;
    AKLinearParameterRamp releaseDurationRamp;
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

        // do ramping every 8 samples
        if ((frameOffset & 0x7) == 0) {
            data->attackDurationRamp.advanceTo(now + frameOffset);
            data->decayDurationRamp.advanceTo(now + frameOffset);
            data->sustainLevelRamp.advanceTo(now + frameOffset);
            data->releaseDurationRamp.advanceTo(now + frameOffset);
        }

        data->adsr->atk = data->attackDurationRamp.getValue();
        data->adsr->dec = data->decayDurationRamp.getValue();
        data->adsr->sus = data->sustainLevelRamp.getValue();
        data->adsr->rel = data->releaseDurationRamp.getValue();

        sp_adsr_compute(sp, data->adsr, &data->internalGate, &data->amp);

        for (int channel = 0; channel < channelCount; ++channel) {
            float *in  = (float *)inputBufferLists[0]->mBuffers[channel].mData  + frameOffset;
            float *out = (float *)outputBufferLists[0]->mBuffers[channel].mData + frameOffset;
            *out = *in * data->amp;
        }
    }
}
