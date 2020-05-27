// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "AKAutoWahDSP.hpp"
#include "ParameterRamper.hpp"

extern "C" AKDSPRef createAutoWahDSP() {
    return new AKAutoWahDSP();
}

struct AKAutoWahDSP::InternalData {
    sp_autowah *autowah0;
    sp_autowah *autowah1;
    ParameterRamper wahRamp;
    ParameterRamper mixRamp;
    ParameterRamper amplitudeRamp;
};

AKAutoWahDSP::AKAutoWahDSP() : data(new InternalData) {
    parameters[AKAutoWahParameterWah] = &data->wahRamp;
    parameters[AKAutoWahParameterMix] = &data->mixRamp;
    parameters[AKAutoWahParameterAmplitude] = &data->amplitudeRamp;
}

void AKAutoWahDSP::init(int channelCount, double sampleRate) {
    AKSoundpipeDSPBase::init(channelCount, sampleRate);
    sp_autowah_create(&data->autowah0);
    sp_autowah_init(sp, data->autowah0);
    sp_autowah_create(&data->autowah1);
    sp_autowah_init(sp, data->autowah1);
}

void AKAutoWahDSP::deinit() {
    AKSoundpipeDSPBase::deinit();
    sp_autowah_destroy(&data->autowah0);
    sp_autowah_destroy(&data->autowah1);
}

void AKAutoWahDSP::reset() {
    AKSoundpipeDSPBase::reset();
    if (!isInitialized) return;
    sp_autowah_init(sp, data->autowah0);
    sp_autowah_init(sp, data->autowah1);
}

void AKAutoWahDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);

        float wah = data->wahRamp.getAndStep();
        *data->autowah0->wah = wah;
        *data->autowah1->wah = wah;

        float mix = data->mixRamp.getAndStep() * 100.f;
        *data->autowah0->mix = mix;
        *data->autowah1->mix = mix;

        float amplitude = data->amplitudeRamp.getAndStep();
        *data->autowah0->level = amplitude;
        *data->autowah1->level = amplitude;

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
                sp_autowah_compute(sp, data->autowah0, in, out);
            } else {
                sp_autowah_compute(sp, data->autowah1, in, out);
            }
        }
    }
}
