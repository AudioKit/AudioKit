// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "SoundpipeDSPBase.h"
#include "ParameterRamper.h"
#include "soundpipe.h"

enum KorgLowPassFilterParameter : AUParameterAddress {
    KorgLowPassFilterParameterCutoffFrequency,
    KorgLowPassFilterParameterResonance,
    KorgLowPassFilterParameterSaturation,
};

class KorgLowPassFilterDSP : public SoundpipeDSPBase {
private:
    sp_wpkorg35 *wpkorg350;
    sp_wpkorg35 *wpkorg351;
    ParameterRamper cutoffFrequencyRamp;
    ParameterRamper resonanceRamp;
    ParameterRamper saturationRamp;

public:
    KorgLowPassFilterDSP() {
        parameters[KorgLowPassFilterParameterCutoffFrequency] = &cutoffFrequencyRamp;
        parameters[KorgLowPassFilterParameterResonance] = &resonanceRamp;
        parameters[KorgLowPassFilterParameterSaturation] = &saturationRamp;
    }

    void init(int channelCount, double sampleRate) override {
        SoundpipeDSPBase::init(channelCount, sampleRate);
        sp_wpkorg35_create(&wpkorg350);
        sp_wpkorg35_init(sp, wpkorg350);
        sp_wpkorg35_create(&wpkorg351);
        sp_wpkorg35_init(sp, wpkorg351);
    }

    void deinit() override {
        SoundpipeDSPBase::deinit();
        sp_wpkorg35_destroy(&wpkorg350);
        sp_wpkorg35_destroy(&wpkorg351);
    }

    void reset() override {
        SoundpipeDSPBase::reset();
        if (!isInitialized) return;
        sp_wpkorg35_init(sp, wpkorg350);
        sp_wpkorg35_init(sp, wpkorg351);
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {
        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            int frameOffset = int(frameIndex + bufferOffset);

            float cutoffFrequency = cutoffFrequencyRamp.getAndStep() - 0.0001f;
            wpkorg350->cutoff = cutoffFrequency;
            wpkorg351->cutoff = cutoffFrequency;

            float resonance = resonanceRamp.getAndStep();
            wpkorg350->res = resonance;
            wpkorg351->res = resonance;

            float saturation = saturationRamp.getAndStep();
            wpkorg350->saturation = saturation;
            wpkorg351->saturation = saturation;

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
                    sp_wpkorg35_compute(sp, wpkorg350, in, out);
                } else {
                    sp_wpkorg35_compute(sp, wpkorg351, in, out);
                }
            }
        }
    }
};

AK_REGISTER_DSP(KorgLowPassFilterDSP, "klpf")
AK_REGISTER_PARAMETER(KorgLowPassFilterParameterCutoffFrequency)
AK_REGISTER_PARAMETER(KorgLowPassFilterParameterResonance)
AK_REGISTER_PARAMETER(KorgLowPassFilterParameterSaturation)
