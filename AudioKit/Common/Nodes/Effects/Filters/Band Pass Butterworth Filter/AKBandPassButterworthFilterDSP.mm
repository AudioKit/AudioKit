// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "AKBandPassButterworthFilterDSP.hpp"
#include "AKLinearParameterRamp.hpp"

extern "C" AKDSPRef createBandPassButterworthFilterDSP() {
    return new AKBandPassButterworthFilterDSP();
}

struct AKBandPassButterworthFilterDSP::InternalData {
    sp_butbp *butbp0;
    sp_butbp *butbp1;
    AKLinearParameterRamp centerFrequencyRamp;
    AKLinearParameterRamp bandwidthRamp;
};

AKBandPassButterworthFilterDSP::AKBandPassButterworthFilterDSP() : data(new InternalData) {
    parameters[AKBandPassButterworthFilterParameterCenterFrequency] = &data->centerFrequencyRamp;
    parameters[AKBandPassButterworthFilterParameterBandwidth] = &data->bandwidthRamp;
}

void AKBandPassButterworthFilterDSP::init(int channelCount, double sampleRate) {
    AKSoundpipeDSPBase::init(channelCount, sampleRate);
    sp_butbp_create(&data->butbp0);
    sp_butbp_init(sp, data->butbp0);
    sp_butbp_create(&data->butbp1);
    sp_butbp_init(sp, data->butbp1);
}

void AKBandPassButterworthFilterDSP::deinit() {
    AKSoundpipeDSPBase::deinit();
    sp_butbp_destroy(&data->butbp0);
    sp_butbp_destroy(&data->butbp1);
}

void AKBandPassButterworthFilterDSP::reset() {
    AKSoundpipeDSPBase::reset();
    if (!isInitialized) return;
    sp_butbp_init(sp, data->butbp0);
    sp_butbp_init(sp, data->butbp1);
}

void AKBandPassButterworthFilterDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);

        // do ramping every 8 samples
        if ((frameOffset & 0x7) == 0) {
            data->centerFrequencyRamp.advanceTo(now + frameOffset);
            data->bandwidthRamp.advanceTo(now + frameOffset);
        }

        data->butbp0->freq = data->centerFrequencyRamp.getValue();
        data->butbp1->freq = data->centerFrequencyRamp.getValue();
        data->butbp0->bw = data->bandwidthRamp.getValue();
        data->butbp1->bw = data->bandwidthRamp.getValue();

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
                sp_butbp_compute(sp, data->butbp0, in, out);
            } else {
                sp_butbp_compute(sp, data->butbp1, in, out);
            }
        }
    }
}
