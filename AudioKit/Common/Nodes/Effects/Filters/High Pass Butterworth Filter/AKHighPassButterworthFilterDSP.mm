// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "AKHighPassButterworthFilterDSP.hpp"
#include "ParameterRamper.hpp"

extern "C" AKDSPRef createHighPassButterworthFilterDSP() {
    return new AKHighPassButterworthFilterDSP();
}

struct AKHighPassButterworthFilterDSP::InternalData {
    sp_buthp *buthp0;
    sp_buthp *buthp1;
    ParameterRamper cutoffFrequencyRamp;
};

AKHighPassButterworthFilterDSP::AKHighPassButterworthFilterDSP() : data(new InternalData) {
    parameters[AKHighPassButterworthFilterParameterCutoffFrequency] = &data->cutoffFrequencyRamp;
}

void AKHighPassButterworthFilterDSP::init(int channelCount, double sampleRate) {
    AKSoundpipeDSPBase::init(channelCount, sampleRate);
    sp_buthp_create(&data->buthp0);
    sp_buthp_init(sp, data->buthp0);
    sp_buthp_create(&data->buthp1);
    sp_buthp_init(sp, data->buthp1);
}

void AKHighPassButterworthFilterDSP::deinit() {
    AKSoundpipeDSPBase::deinit();
    sp_buthp_destroy(&data->buthp0);
    sp_buthp_destroy(&data->buthp1);
}

void AKHighPassButterworthFilterDSP::reset() {
    AKSoundpipeDSPBase::reset();
    if (!isInitialized) return;
    sp_buthp_init(sp, data->buthp0);
    sp_buthp_init(sp, data->buthp1);
}

void AKHighPassButterworthFilterDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);

        float cutoffFrequency = data->cutoffFrequencyRamp.getAndStep();
        data->buthp0->freq = cutoffFrequency;
        data->buthp1->freq = cutoffFrequency;

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
                sp_buthp_compute(sp, data->buthp0, in, out);
            } else {
                sp_buthp_compute(sp, data->buthp1, in, out);
            }
        }
    }
}
