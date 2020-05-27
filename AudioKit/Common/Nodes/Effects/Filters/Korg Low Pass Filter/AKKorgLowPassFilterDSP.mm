// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "AKKorgLowPassFilterDSP.hpp"
#include "ParameterRamper.hpp"

extern "C" AKDSPRef createKorgLowPassFilterDSP() {
    return new AKKorgLowPassFilterDSP();
}

struct AKKorgLowPassFilterDSP::InternalData {
    sp_wpkorg35 *wpkorg350;
    sp_wpkorg35 *wpkorg351;
    ParameterRamper cutoffFrequencyRamp;
    ParameterRamper resonanceRamp;
    ParameterRamper saturationRamp;
};

AKKorgLowPassFilterDSP::AKKorgLowPassFilterDSP() : data(new InternalData) {
    parameters[AKKorgLowPassFilterParameterCutoffFrequency] = &data->cutoffFrequencyRamp;
    parameters[AKKorgLowPassFilterParameterResonance] = &data->resonanceRamp;
    parameters[AKKorgLowPassFilterParameterSaturation] = &data->saturationRamp;
}

void AKKorgLowPassFilterDSP::init(int channelCount, double sampleRate) {
    AKSoundpipeDSPBase::init(channelCount, sampleRate);
    sp_wpkorg35_create(&data->wpkorg350);
    sp_wpkorg35_init(sp, data->wpkorg350);
    sp_wpkorg35_create(&data->wpkorg351);
    sp_wpkorg35_init(sp, data->wpkorg351);
}

void AKKorgLowPassFilterDSP::deinit() {
    AKSoundpipeDSPBase::deinit();
    sp_wpkorg35_destroy(&data->wpkorg350);
    sp_wpkorg35_destroy(&data->wpkorg351);
}

void AKKorgLowPassFilterDSP::reset() {
    AKSoundpipeDSPBase::reset();
    if (!isInitialized) return;
    sp_wpkorg35_init(sp, data->wpkorg350);
    sp_wpkorg35_init(sp, data->wpkorg351);
}

void AKKorgLowPassFilterDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);

        float cutoffFrequency = data->cutoffFrequencyRamp.getAndStep() - 0.0001f;
        data->wpkorg350->cutoff = cutoffFrequency;
        data->wpkorg351->cutoff = cutoffFrequency;

        float resonance = data->resonanceRamp.getAndStep();
        data->wpkorg350->res = resonance;
        data->wpkorg351->res = resonance;

        float saturation = data->saturationRamp.getAndStep();
        data->wpkorg350->saturation = saturation;
        data->wpkorg351->saturation = saturation;

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
                sp_wpkorg35_compute(sp, data->wpkorg350, in, out);
            } else {
                sp_wpkorg35_compute(sp, data->wpkorg351, in, out);
            }
        }
    }
}
