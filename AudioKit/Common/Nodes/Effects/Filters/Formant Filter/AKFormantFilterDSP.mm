// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "AKFormantFilterDSP.hpp"
#include "ParameterRamper.hpp"

extern "C" AKDSPRef createFormantFilterDSP() {
    return new AKFormantFilterDSP();
}

struct AKFormantFilterDSP::InternalData {
    sp_fofilt *fofilt0;
    sp_fofilt *fofilt1;
    ParameterRamper centerFrequencyRamp;
    ParameterRamper attackDurationRamp;
    ParameterRamper decayDurationRamp;
};

AKFormantFilterDSP::AKFormantFilterDSP() : data(new InternalData) {
    parameters[AKFormantFilterParameterCenterFrequency] = &data->centerFrequencyRamp;
    parameters[AKFormantFilterParameterAttackDuration] = &data->attackDurationRamp;
    parameters[AKFormantFilterParameterDecayDuration] = &data->decayDurationRamp;
}

void AKFormantFilterDSP::init(int channelCount, double sampleRate) {
    AKSoundpipeDSPBase::init(channelCount, sampleRate);
    sp_fofilt_create(&data->fofilt0);
    sp_fofilt_init(sp, data->fofilt0);
    sp_fofilt_create(&data->fofilt1);
    sp_fofilt_init(sp, data->fofilt1);
}

void AKFormantFilterDSP::deinit() {
    AKSoundpipeDSPBase::deinit();
    sp_fofilt_destroy(&data->fofilt0);
    sp_fofilt_destroy(&data->fofilt1);
}

void AKFormantFilterDSP::reset() {
    AKSoundpipeDSPBase::reset();
    if (!isInitialized) return;
    sp_fofilt_init(sp, data->fofilt0);
    sp_fofilt_init(sp, data->fofilt1);
}

void AKFormantFilterDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);

        float centerFrequency = data->centerFrequencyRamp.getAndStep();
        data->fofilt0->freq = centerFrequency;
        data->fofilt1->freq = centerFrequency;

        float attackDuration = data->attackDurationRamp.getAndStep();
        data->fofilt0->atk = attackDuration;
        data->fofilt1->atk = attackDuration;

        float decayDuration = data->decayDurationRamp.getAndStep();
        data->fofilt0->dec = decayDuration;
        data->fofilt1->dec = decayDuration;

        float *tmpin[2];
        float *tmpout[2];
        for (int channel = 0; channel < channelCount; ++channel) {
            float *in  = (float *)inputBufferLists[0]->mBuffers[channel].mData  + frameOffset;
            float *out = (float *)outputBufferLists[0]->mBuffers[channel].mData + frameOffset;
            if (channel < 2) {
                tmpin[channel] = in;
                tmpout[channel] = out;
            }
            if (!isStarted) {
                *out = *in;
                continue;
            }

            if (channel == 0) {
                sp_fofilt_compute(sp, data->fofilt0, in, out);
            } else {
                sp_fofilt_compute(sp, data->fofilt1, in, out);
            }
        }
    }
}
