// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "AKResonantFilterDSP.hpp"
#include "ParameterRamper.hpp"

extern "C" AKDSPRef createResonantFilterDSP() {
    return new AKResonantFilterDSP();
}

struct AKResonantFilterDSP::InternalData {
    sp_reson *reson0;
    sp_reson *reson1;
    ParameterRamper frequencyRamp;
    ParameterRamper bandwidthRamp;
};

AKResonantFilterDSP::AKResonantFilterDSP() : data(new InternalData) {
    parameters[AKResonantFilterParameterFrequency] = &data->frequencyRamp;
    parameters[AKResonantFilterParameterBandwidth] = &data->bandwidthRamp;
}

void AKResonantFilterDSP::init(int channelCount, double sampleRate) {
    AKSoundpipeDSPBase::init(channelCount, sampleRate);
    sp_reson_create(&data->reson0);
    sp_reson_init(sp, data->reson0);
    sp_reson_create(&data->reson1);
    sp_reson_init(sp, data->reson1);
}

void AKResonantFilterDSP::deinit() {
    AKSoundpipeDSPBase::deinit();
    sp_reson_destroy(&data->reson0);
    sp_reson_destroy(&data->reson1);
}

void AKResonantFilterDSP::reset() {
    AKSoundpipeDSPBase::reset();
    if (!isInitialized) return;
    sp_reson_init(sp, data->reson0);
    sp_reson_init(sp, data->reson1);
}

void AKResonantFilterDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);

        float frequency = data->frequencyRamp.getAndStep();
        data->reson0->freq = frequency;
        data->reson1->freq = frequency;

        float bandwidth = data->bandwidthRamp.getAndStep();
        data->reson0->bw = bandwidth;
        data->reson1->bw = bandwidth;

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
                sp_reson_compute(sp, data->reson0, in, out);
            } else {
                sp_reson_compute(sp, data->reson1, in, out);
            }
        }
    }
}
