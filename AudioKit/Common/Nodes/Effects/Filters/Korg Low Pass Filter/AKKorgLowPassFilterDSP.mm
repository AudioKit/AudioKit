// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "AKKorgLowPassFilterDSP.hpp"
#include "AKLinearParameterRamp.hpp"

extern "C" AKDSPRef createKorgLowPassFilterDSP() {
    return new AKKorgLowPassFilterDSP();
}

struct AKKorgLowPassFilterDSP::InternalData {
    sp_wpkorg35 *wpkorg350;
    sp_wpkorg35 *wpkorg351;
    AKLinearParameterRamp cutoffFrequencyRamp;
    AKLinearParameterRamp resonanceRamp;
    AKLinearParameterRamp saturationRamp;
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

        // do ramping every 8 samples
        if ((frameOffset & 0x7) == 0) {
            data->cutoffFrequencyRamp.advanceTo(now + frameOffset);
            data->resonanceRamp.advanceTo(now + frameOffset);
            data->saturationRamp.advanceTo(now + frameOffset);
        }

        data->wpkorg350->cutoff = data->cutoffFrequencyRamp.getValue() - 0.0001;
        data->wpkorg351->cutoff = data->cutoffFrequencyRamp.getValue() - 0.0001;
        data->wpkorg350->res = data->resonanceRamp.getValue();
        data->wpkorg351->res = data->resonanceRamp.getValue();
        data->wpkorg350->saturation = data->saturationRamp.getValue();
        data->wpkorg351->saturation = data->saturationRamp.getValue();

        float *tmpin[2];
        float *tmpout[2];
        for (int channel = 0; channel < channelCount; ++channel) {
            float *in  = (float *)inBufferListPtr->mBuffers[channel].mData  + frameOffset;
            float *out = (float *)outBufferListPtr->mBuffers[channel].mData + frameOffset;
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
