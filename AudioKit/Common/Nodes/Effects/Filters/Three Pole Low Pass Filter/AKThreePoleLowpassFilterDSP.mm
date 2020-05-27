// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "AKThreePoleLowpassFilterDSP.hpp"
#include "ParameterRamper.hpp"

extern "C" AKDSPRef createThreePoleLowpassFilterDSP() {
    return new AKThreePoleLowpassFilterDSP();
}

struct AKThreePoleLowpassFilterDSP::InternalData {
    sp_lpf18 *lpf180;
    sp_lpf18 *lpf181;
    ParameterRamper distortionRamp;
    ParameterRamper cutoffFrequencyRamp;
    ParameterRamper resonanceRamp;
};

AKThreePoleLowpassFilterDSP::AKThreePoleLowpassFilterDSP() : data(new InternalData) {
    parameters[AKThreePoleLowpassFilterParameterDistortion] = &data->distortionRamp;
    parameters[AKThreePoleLowpassFilterParameterCutoffFrequency] = &data->cutoffFrequencyRamp;
    parameters[AKThreePoleLowpassFilterParameterResonance] = &data->resonanceRamp;
}

void AKThreePoleLowpassFilterDSP::init(int channelCount, double sampleRate) {
    AKSoundpipeDSPBase::init(channelCount, sampleRate);
    sp_lpf18_create(&data->lpf180);
    sp_lpf18_init(sp, data->lpf180);
    sp_lpf18_create(&data->lpf181);
    sp_lpf18_init(sp, data->lpf181);
}

void AKThreePoleLowpassFilterDSP::deinit() {
    AKSoundpipeDSPBase::deinit();
    sp_lpf18_destroy(&data->lpf180);
    sp_lpf18_destroy(&data->lpf181);
}

void AKThreePoleLowpassFilterDSP::reset() {
    AKSoundpipeDSPBase::reset();
    if (!isInitialized) return;
    sp_lpf18_init(sp, data->lpf180);
    sp_lpf18_init(sp, data->lpf181);
}

void AKThreePoleLowpassFilterDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);

        float distortion = data->distortionRamp.getAndStep();
        data->lpf180->dist = distortion;
        data->lpf181->dist = distortion;

        float cutoffFrequency = data->cutoffFrequencyRamp.getAndStep();
        data->lpf180->cutoff = cutoffFrequency;
        data->lpf181->cutoff = cutoffFrequency;

        float resonance = data->resonanceRamp.getAndStep();
        data->lpf180->res = resonance;
        data->lpf181->res = resonance;

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
                sp_lpf18_compute(sp, data->lpf180, in, out);
            } else {
                sp_lpf18_compute(sp, data->lpf181, in, out);
            }
        }
    }
}
