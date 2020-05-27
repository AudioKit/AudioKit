// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "AKMoogLadderDSP.hpp"
#include "ParameterRamper.hpp"

extern "C" AKDSPRef createMoogLadderDSP() {
    return new AKMoogLadderDSP();
}

struct AKMoogLadderDSP::InternalData {
    sp_moogladder *moogladder0;
    sp_moogladder *moogladder1;
    ParameterRamper cutoffFrequencyRamp;
    ParameterRamper resonanceRamp;
};

AKMoogLadderDSP::AKMoogLadderDSP() : data(new InternalData) {
    parameters[AKMoogLadderParameterCutoffFrequency] = &data->cutoffFrequencyRamp;
    parameters[AKMoogLadderParameterResonance] = &data->resonanceRamp;
}

void AKMoogLadderDSP::init(int channelCount, double sampleRate) {
    AKSoundpipeDSPBase::init(channelCount, sampleRate);
    sp_moogladder_create(&data->moogladder0);
    sp_moogladder_init(sp, data->moogladder0);
    sp_moogladder_create(&data->moogladder1);
    sp_moogladder_init(sp, data->moogladder1);
}

void AKMoogLadderDSP::deinit() {
    AKSoundpipeDSPBase::deinit();
    sp_moogladder_destroy(&data->moogladder0);
    sp_moogladder_destroy(&data->moogladder1);
}

void AKMoogLadderDSP::reset() {
    AKSoundpipeDSPBase::reset();
    if (!isInitialized) return;
    sp_moogladder_init(sp, data->moogladder0);
    sp_moogladder_init(sp, data->moogladder1);
}

void AKMoogLadderDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);

        float cutoffFrequency = data->cutoffFrequencyRamp.getAndStep();
        data->moogladder0->freq = cutoffFrequency;
        data->moogladder1->freq = cutoffFrequency;

        float resonance = data->resonanceRamp.getAndStep();
        data->moogladder0->res = resonance;
        data->moogladder1->res = resonance;

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
                sp_moogladder_compute(sp, data->moogladder0, in, out);
            } else {
                sp_moogladder_compute(sp, data->moogladder1, in, out);
            }
        }
    }
}
