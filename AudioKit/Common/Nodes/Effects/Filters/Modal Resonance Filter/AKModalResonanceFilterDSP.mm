// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "AKModalResonanceFilterDSP.hpp"
#include "AKLinearParameterRamp.hpp"

extern "C" AKDSPRef createModalResonanceFilterDSP() {
    return new AKModalResonanceFilterDSP();
}

struct AKModalResonanceFilterDSP::InternalData {
    sp_mode *mode0;
    sp_mode *mode1;
    AKLinearParameterRamp frequencyRamp;
    AKLinearParameterRamp qualityFactorRamp;
};

AKModalResonanceFilterDSP::AKModalResonanceFilterDSP() : data(new InternalData) {
    parameters[AKModalResonanceFilterParameterFrequency] = &data->frequencyRamp;
    parameters[AKModalResonanceFilterParameterQualityFactor] = &data->qualityFactorRamp;
}

void AKModalResonanceFilterDSP::init(int channelCount, double sampleRate) {
    AKSoundpipeDSPBase::init(channelCount, sampleRate);
    sp_mode_create(&data->mode0);
    sp_mode_init(sp, data->mode0);
    sp_mode_create(&data->mode1);
    sp_mode_init(sp, data->mode1);
}

void AKModalResonanceFilterDSP::deinit() {
    AKSoundpipeDSPBase::deinit();
    sp_mode_destroy(&data->mode0);
    sp_mode_destroy(&data->mode1);
}

void AKModalResonanceFilterDSP::reset() {
    AKSoundpipeDSPBase::reset();
    if (!isInitialized) return;
    sp_mode_init(sp, data->mode0);
    sp_mode_init(sp, data->mode1);
}

void AKModalResonanceFilterDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);

        // do ramping every 8 samples
        if ((frameOffset & 0x7) == 0) {
            data->frequencyRamp.advanceTo(now + frameOffset);
            data->qualityFactorRamp.advanceTo(now + frameOffset);
        }

        data->mode0->freq = data->frequencyRamp.getValue();
        data->mode1->freq = data->frequencyRamp.getValue();
        data->mode0->q = data->qualityFactorRamp.getValue();
        data->mode1->q = data->qualityFactorRamp.getValue();

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
                sp_mode_compute(sp, data->mode0, in, out);
            } else {
                sp_mode_compute(sp, data->mode1, in, out);
            }
        }
    }
}
