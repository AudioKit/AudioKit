// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "AKFlatFrequencyResponseReverbDSP.hpp"
#include "ParameterRamper.hpp"

extern "C" AKDSPRef createFlatFrequencyResponseReverbDSP() {
    return new AKFlatFrequencyResponseReverbDSP();
}

extern "C" void setLoopDurationFlatFrequencyResponseReverbDSP(AKDSPRef dsp, float duration) {
    ((AKFlatFrequencyResponseReverbDSP*)dsp)->setLoopDuration(duration);
}

struct AKFlatFrequencyResponseReverbDSP::InternalData {
    sp_allpass *allpass0;
    sp_allpass *allpass1;
    float loopDuration = 0.1;
    ParameterRamper reverbDurationRamp;
};

AKFlatFrequencyResponseReverbDSP::AKFlatFrequencyResponseReverbDSP() : data(new InternalData) {
    parameters[AKFlatFrequencyResponseReverbParameterReverbDuration] = &data->reverbDurationRamp;
}

void AKFlatFrequencyResponseReverbDSP::setLoopDuration(float duration) {
    data->loopDuration = duration;
    reset();
}

void AKFlatFrequencyResponseReverbDSP::init(int channelCount, double sampleRate) {
    AKSoundpipeDSPBase::init(channelCount, sampleRate);
    sp_allpass_create(&data->allpass0);
    sp_allpass_init(sp, data->allpass0, data->loopDuration);
    sp_allpass_create(&data->allpass1);
    sp_allpass_init(sp, data->allpass1, data->loopDuration);
}

void AKFlatFrequencyResponseReverbDSP::deinit() {
    AKSoundpipeDSPBase::deinit();
    sp_allpass_destroy(&data->allpass0);
    sp_allpass_destroy(&data->allpass1);
}

void AKFlatFrequencyResponseReverbDSP::reset() {
    AKSoundpipeDSPBase::reset();
    if (!isInitialized) return;
    sp_allpass_init(sp, data->allpass0, data->loopDuration);
    sp_allpass_init(sp, data->allpass1, data->loopDuration);
}

void AKFlatFrequencyResponseReverbDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);

        float reverbDuration = data->reverbDurationRamp.getAndStep();
        data->allpass0->revtime = reverbDuration;
        data->allpass1->revtime = reverbDuration;

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
                sp_allpass_compute(sp, data->allpass0, in, out);
            } else {
                sp_allpass_compute(sp, data->allpass1, in, out);
            }
        }
    }
}
