// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "AKRolandTB303FilterDSP.hpp"
#include "AKLinearParameterRamp.hpp"

extern "C" AKDSPRef createRolandTB303FilterDSP() {
    return new AKRolandTB303FilterDSP();
}

struct AKRolandTB303FilterDSP::InternalData {
    sp_tbvcf *tbvcf0;
    sp_tbvcf *tbvcf1;
    AKLinearParameterRamp cutoffFrequencyRamp;
    AKLinearParameterRamp resonanceRamp;
    AKLinearParameterRamp distortionRamp;
    AKLinearParameterRamp resonanceAsymmetryRamp;
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

        // do ramping every 8 samples
        if ((frameOffset & 0x7) == 0) {
            data->cutoffFrequencyRamp.advanceTo(now + frameOffset);
            data->resonanceRamp.advanceTo(now + frameOffset);
            data->distortionRamp.advanceTo(now + frameOffset);
            data->resonanceAsymmetryRamp.advanceTo(now + frameOffset);
        }

        data->tbvcf0->fco = data->cutoffFrequencyRamp.getValue();
        data->tbvcf1->fco = data->cutoffFrequencyRamp.getValue();
        data->tbvcf0->res = data->resonanceRamp.getValue();
        data->tbvcf1->res = data->resonanceRamp.getValue();
        data->tbvcf0->dist = data->distortionRamp.getValue();
        data->tbvcf1->dist = data->distortionRamp.getValue();
        data->tbvcf0->asym = data->resonanceAsymmetryRamp.getValue();
        data->tbvcf1->asym = data->resonanceAsymmetryRamp.getValue();

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
                sp_tbvcf_compute(sp, data->tbvcf0, in, out);
            } else {
                sp_tbvcf_compute(sp, data->tbvcf1, in, out);
            }
        }
    }
}
