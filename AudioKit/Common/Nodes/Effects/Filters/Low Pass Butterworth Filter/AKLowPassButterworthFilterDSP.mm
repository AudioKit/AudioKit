// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "AKLowPassButterworthFilterDSP.hpp"
#include "ParameterRamper.hpp"

extern "C" AKDSPRef createLowPassButterworthFilterDSP() {
    return new AKLowPassButterworthFilterDSP();
}

struct AKLowPassButterworthFilterDSP::InternalData {
    sp_butlp *butlp0;
    sp_butlp *butlp1;
    ParameterRamper cutoffFrequencyRamp;
};

AKLowPassButterworthFilterDSP::AKLowPassButterworthFilterDSP() : data(new InternalData) {
    parameters[AKLowPassButterworthFilterParameterCutoffFrequency] = &data->cutoffFrequencyRamp;
}

void AKLowPassButterworthFilterDSP::init(int channelCount, double sampleRate) {
    AKSoundpipeDSPBase::init(channelCount, sampleRate);
    sp_butlp_create(&data->butlp0);
    sp_butlp_init(sp, data->butlp0);
    sp_butlp_create(&data->butlp1);
    sp_butlp_init(sp, data->butlp1);
}

void AKLowPassButterworthFilterDSP::deinit() {
    AKSoundpipeDSPBase::deinit();
    sp_butlp_destroy(&data->butlp0);
    sp_butlp_destroy(&data->butlp1);
}

void AKLowPassButterworthFilterDSP::reset() {
    AKSoundpipeDSPBase::reset();
    if (!isInitialized) return;
    sp_butlp_init(sp, data->butlp0);
    sp_butlp_init(sp, data->butlp1);
}

void AKLowPassButterworthFilterDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);

        float cutoffFrequency = data->cutoffFrequencyRamp.getAndStep();
        data->butlp0->freq = cutoffFrequency;
        data->butlp1->freq = cutoffFrequency;

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
                sp_butlp_compute(sp, data->butlp0, in, out);
            } else {
                sp_butlp_compute(sp, data->butlp1, in, out);
            }
        }
    }
}
