// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "AKHighPassButterworthFilterDSP.hpp"
#include "AKLinearParameterRamp.hpp"

extern "C" AKDSPRef createHighPassButterworthFilterDSP() {
    return new AKHighPassButterworthFilterDSP();
}

struct AKHighPassButterworthFilterDSP::InternalData {
    sp_buthp *buthp0;
    sp_buthp *buthp1;
    AKLinearParameterRamp cutoffFrequencyRamp;
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

        // do ramping every 8 samples
        if ((frameOffset & 0x7) == 0) {
            data->cutoffFrequencyRamp.advanceTo(now + frameOffset);
        }

        data->buthp0->freq = data->cutoffFrequencyRamp.getValue();
        data->buthp1->freq = data->cutoffFrequencyRamp.getValue();

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
                sp_buthp_compute(sp, data->buthp0, in, out);
            } else {
                sp_buthp_compute(sp, data->buthp1, in, out);
            }
        }
    }
}
