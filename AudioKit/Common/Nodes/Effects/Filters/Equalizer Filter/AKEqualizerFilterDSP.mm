// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "AKEqualizerFilterDSP.hpp"
#include "AKLinearParameterRamp.hpp"

extern "C" AKDSPRef createEqualizerFilterDSP() {
    return new AKEqualizerFilterDSP();
}

struct AKEqualizerFilterDSP::InternalData {
    sp_eqfil *eqfil0;
    sp_eqfil *eqfil1;
    AKLinearParameterRamp centerFrequencyRamp;
    AKLinearParameterRamp bandwidthRamp;
    AKLinearParameterRamp gainRamp;
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

        // do ramping every 8 samples
        if ((frameOffset & 0x7) == 0) {
            data->centerFrequencyRamp.advanceTo(now + frameOffset);
            data->bandwidthRamp.advanceTo(now + frameOffset);
            data->gainRamp.advanceTo(now + frameOffset);
        }

        data->eqfil0->freq = data->centerFrequencyRamp.getValue();
        data->eqfil1->freq = data->centerFrequencyRamp.getValue();
        data->eqfil0->bw = data->bandwidthRamp.getValue();
        data->eqfil1->bw = data->bandwidthRamp.getValue();
        data->eqfil0->gain = data->gainRamp.getValue();
        data->eqfil1->gain = data->gainRamp.getValue();

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
                sp_eqfil_compute(sp, data->eqfil0, in, out);
            } else {
                sp_eqfil_compute(sp, data->eqfil1, in, out);
            }
        }
    }
}
