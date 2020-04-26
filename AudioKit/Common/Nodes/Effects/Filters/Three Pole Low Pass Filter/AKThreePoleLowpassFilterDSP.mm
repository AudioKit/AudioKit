// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "AKThreePoleLowpassFilterDSP.hpp"
#include "AKLinearParameterRamp.hpp"

extern "C" AKDSPRef createThreePoleLowpassFilterDSP() {
    return new AKThreePoleLowpassFilterDSP();
}

struct AKThreePoleLowpassFilterDSP::InternalData {
    sp_lpf18 *lpf180;
    sp_lpf18 *lpf181;
    AKLinearParameterRamp distortionRamp;
    AKLinearParameterRamp cutoffFrequencyRamp;
    AKLinearParameterRamp resonanceRamp;
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

        // do ramping every 8 samples
        if ((frameOffset & 0x7) == 0) {
            data->distortionRamp.advanceTo(now + frameOffset);
            data->cutoffFrequencyRamp.advanceTo(now + frameOffset);
            data->resonanceRamp.advanceTo(now + frameOffset);
        }

        data->lpf180->dist = data->distortionRamp.getValue();
        data->lpf181->dist = data->distortionRamp.getValue();
        data->lpf180->cutoff = data->cutoffFrequencyRamp.getValue();
        data->lpf181->cutoff = data->cutoffFrequencyRamp.getValue();
        data->lpf180->res = data->resonanceRamp.getValue();
        data->lpf181->res = data->resonanceRamp.getValue();

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
                sp_lpf18_compute(sp, data->lpf180, in, out);
            } else {
                sp_lpf18_compute(sp, data->lpf181, in, out);
            }
        }
    }
}
