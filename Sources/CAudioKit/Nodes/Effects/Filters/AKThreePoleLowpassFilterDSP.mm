// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "AKSoundpipeDSPBase.hpp"
#include "ParameterRamper.hpp"
#include "soundpipe.h"

enum AKThreePoleLowpassFilterParameter : AUParameterAddress {
    AKThreePoleLowpassFilterParameterDistortion,
    AKThreePoleLowpassFilterParameterCutoffFrequency,
    AKThreePoleLowpassFilterParameterResonance,
};

class AKThreePoleLowpassFilterDSP : public AKSoundpipeDSPBase {
private:
    sp_lpf18 *lpf180;
    sp_lpf18 *lpf181;
    ParameterRamper distortionRamp;
    ParameterRamper cutoffFrequencyRamp;
    ParameterRamper resonanceRamp;

public:
    AKThreePoleLowpassFilterDSP() {
        parameters[AKThreePoleLowpassFilterParameterDistortion] = &distortionRamp;
        parameters[AKThreePoleLowpassFilterParameterCutoffFrequency] = &cutoffFrequencyRamp;
        parameters[AKThreePoleLowpassFilterParameterResonance] = &resonanceRamp;
    }

    void init(int channelCount, double sampleRate) override {
        AKSoundpipeDSPBase::init(channelCount, sampleRate);
        sp_lpf18_create(&lpf180);
        sp_lpf18_init(sp, lpf180);
        sp_lpf18_create(&lpf181);
        sp_lpf18_init(sp, lpf181);
    }

    void deinit() override {
        AKSoundpipeDSPBase::deinit();
        sp_lpf18_destroy(&lpf180);
        sp_lpf18_destroy(&lpf181);
    }

    void reset() override {
        AKSoundpipeDSPBase::reset();
        if (!isInitialized) return;
        sp_lpf18_init(sp, lpf180);
        sp_lpf18_init(sp, lpf181);
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {
        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            int frameOffset = int(frameIndex + bufferOffset);

            float distortion = distortionRamp.getAndStep();
            lpf180->dist = distortion;
            lpf181->dist = distortion;

            float cutoffFrequency = cutoffFrequencyRamp.getAndStep();
            lpf180->cutoff = cutoffFrequency;
            lpf181->cutoff = cutoffFrequency;

            float resonance = resonanceRamp.getAndStep();
            lpf180->res = resonance;
            lpf181->res = resonance;

            float *tmpin[2];
            float *tmpout[2];
            for (int channel = 0; channel < channelCount; ++channel) {
                float *in  = (float *)inputBufferLists[0]->mBuffers[channel].mData  + frameOffset;
                float *out = (float *)outputBufferList->mBuffers[channel].mData + frameOffset;
                if (channel < 2) {
                    tmpin[channel] = in;
                    tmpout[channel] = out;
                }
                if (!isStarted) {
                    *out = *in;
                    continue;
                }

                if (channel == 0) {
                    sp_lpf18_compute(sp, lpf180, in, out);
                } else {
                    sp_lpf18_compute(sp, lpf181, in, out);
                }
            }
        }
    }
};

AK_REGISTER_DSP(AKThreePoleLowpassFilterDSP)
AK_REGISTER_PARAMETER(AKThreePoleLowpassFilterParameterDistortion)
AK_REGISTER_PARAMETER(AKThreePoleLowpassFilterParameterCutoffFrequency)
AK_REGISTER_PARAMETER(AKThreePoleLowpassFilterParameterResonance)
