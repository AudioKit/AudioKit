// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "AKEqualizerFilterDSP.hpp"
#include "ParameterRamper.hpp"

extern "C" AKDSPRef createEqualizerFilterDSP() {
    return new AKEqualizerFilterDSP();
}

struct AKEqualizerFilterDSP::InternalData {
    sp_eqfil *eqfil0;
    sp_eqfil *eqfil1;
    ParameterRamper centerFrequencyRamp;
    ParameterRamper bandwidthRamp;
    ParameterRamper gainRamp;
};

AKEqualizerFilterDSP::AKEqualizerFilterDSP() : data(new InternalData) {
    parameters[AKEqualizerFilterParameterCenterFrequency] = &data->centerFrequencyRamp;
    parameters[AKEqualizerFilterParameterBandwidth] = &data->bandwidthRamp;
    parameters[AKEqualizerFilterParameterGain] = &data->gainRamp;
}

void AKEqualizerFilterDSP::init(int channelCount, double sampleRate) {
    AKSoundpipeDSPBase::init(channelCount, sampleRate);
    sp_eqfil_create(&data->eqfil0);
    sp_eqfil_init(sp, data->eqfil0);
    sp_eqfil_create(&data->eqfil1);
    sp_eqfil_init(sp, data->eqfil1);
}

void AKEqualizerFilterDSP::deinit() {
    AKSoundpipeDSPBase::deinit();
    sp_eqfil_destroy(&data->eqfil0);
    sp_eqfil_destroy(&data->eqfil1);
}

void AKEqualizerFilterDSP::reset() {
    AKSoundpipeDSPBase::reset();
    if (!isInitialized) return;
    sp_eqfil_init(sp, data->eqfil0);
    sp_eqfil_init(sp, data->eqfil1);
}

void AKEqualizerFilterDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);

        float centerFrequency = data->centerFrequencyRamp.getAndStep();
        data->eqfil0->freq = centerFrequency;
        data->eqfil1->freq = centerFrequency;

        float bandwidth = data->bandwidthRamp.getAndStep();
        data->eqfil0->bw = bandwidth;
        data->eqfil1->bw = bandwidth;

        float gain = data->gainRamp.getAndStep();
        data->eqfil0->gain = gain;
        data->eqfil1->gain = gain;

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
                sp_eqfil_compute(sp, data->eqfil0, in, out);
            } else {
                sp_eqfil_compute(sp, data->eqfil1, in, out);
            }
        }
    }
}
