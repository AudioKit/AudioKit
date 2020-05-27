// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "AKRolandTB303FilterDSP.hpp"
#include "ParameterRamper.hpp"

extern "C" AKDSPRef createRolandTB303FilterDSP() {
    return new AKRolandTB303FilterDSP();
}

struct AKRolandTB303FilterDSP::InternalData {
    sp_tbvcf *tbvcf0;
    sp_tbvcf *tbvcf1;
    ParameterRamper cutoffFrequencyRamp;
    ParameterRamper resonanceRamp;
    ParameterRamper distortionRamp;
    ParameterRamper resonanceAsymmetryRamp;
};

AKRolandTB303FilterDSP::AKRolandTB303FilterDSP() : data(new InternalData) {
    parameters[AKRolandTB303FilterParameterCutoffFrequency] = &data->cutoffFrequencyRamp;
    parameters[AKRolandTB303FilterParameterResonance] = &data->resonanceRamp;
    parameters[AKRolandTB303FilterParameterDistortion] = &data->distortionRamp;
    parameters[AKRolandTB303FilterParameterResonanceAsymmetry] = &data->resonanceAsymmetryRamp;
}

void AKRolandTB303FilterDSP::init(int channelCount, double sampleRate) {
    AKSoundpipeDSPBase::init(channelCount, sampleRate);
    sp_tbvcf_create(&data->tbvcf0);
    sp_tbvcf_init(sp, data->tbvcf0);
    sp_tbvcf_create(&data->tbvcf1);
    sp_tbvcf_init(sp, data->tbvcf1);
}

void AKRolandTB303FilterDSP::deinit() {
    AKSoundpipeDSPBase::deinit();
    sp_tbvcf_destroy(&data->tbvcf0);
    sp_tbvcf_destroy(&data->tbvcf1);
}

void AKRolandTB303FilterDSP::reset() {
    AKSoundpipeDSPBase::reset();
    if (!isInitialized) return;
    sp_tbvcf_init(sp, data->tbvcf0);
    sp_tbvcf_init(sp, data->tbvcf1);
}

void AKRolandTB303FilterDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);

        float cutoffFrequency = data->cutoffFrequencyRamp.getAndStep();
        data->tbvcf0->fco = cutoffFrequency;
        data->tbvcf1->fco = cutoffFrequency;

        float resonance = data->resonanceRamp.getAndStep();
        data->tbvcf0->res = resonance;
        data->tbvcf1->res = resonance;

        float distortion = data->distortionRamp.getAndStep();
        data->tbvcf0->dist = distortion;
        data->tbvcf1->dist = distortion;

        float resonanceAsymmetry = data->resonanceAsymmetryRamp.getAndStep();
        data->tbvcf0->asym = resonanceAsymmetry;
        data->tbvcf1->asym = resonanceAsymmetry;

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
                sp_tbvcf_compute(sp, data->tbvcf0, in, out);
            } else {
                sp_tbvcf_compute(sp, data->tbvcf1, in, out);
            }
        }
    }
}
