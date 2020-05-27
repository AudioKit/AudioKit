// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "AKBandRejectButterworthFilterDSP.hpp"
#include "ParameterRamper.hpp"

extern "C" AKDSPRef createBandRejectButterworthFilterDSP() {
    return new AKBandRejectButterworthFilterDSP();
}

struct AKBandRejectButterworthFilterDSP::InternalData {
    sp_butbr *butbr0;
    sp_butbr *butbr1;
    ParameterRamper centerFrequencyRamp;
    ParameterRamper bandwidthRamp;
};

AKBandRejectButterworthFilterDSP::AKBandRejectButterworthFilterDSP() : data(new InternalData) {
    parameters[AKBandRejectButterworthFilterParameterCenterFrequency] = &data->centerFrequencyRamp;
    parameters[AKBandRejectButterworthFilterParameterBandwidth] = &data->bandwidthRamp;
}

void AKBandRejectButterworthFilterDSP::init(int channelCount, double sampleRate) {
    AKSoundpipeDSPBase::init(channelCount, sampleRate);
    sp_butbr_create(&data->butbr0);
    sp_butbr_init(sp, data->butbr0);
    sp_butbr_create(&data->butbr1);
    sp_butbr_init(sp, data->butbr1);
}

void AKBandRejectButterworthFilterDSP::deinit() {
    AKSoundpipeDSPBase::deinit();
    sp_butbr_destroy(&data->butbr0);
    sp_butbr_destroy(&data->butbr1);
}

void AKBandRejectButterworthFilterDSP::reset() {
    AKSoundpipeDSPBase::reset();
    if (!isInitialized) return;
    sp_butbr_init(sp, data->butbr0);
    sp_butbr_init(sp, data->butbr1);
}

void AKBandRejectButterworthFilterDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);

        float centerFrequency = data->centerFrequencyRamp.getAndStep();
        data->butbr0->freq = centerFrequency;
        data->butbr1->freq = centerFrequency;

        float bandwidth = data->bandwidthRamp.getAndStep();
        data->butbr0->bw = bandwidth;
        data->butbr1->bw = bandwidth;

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
                sp_butbr_compute(sp, data->butbr0, in, out);
            } else {
                sp_butbr_compute(sp, data->butbr1, in, out);
            }
        }
    }
}
