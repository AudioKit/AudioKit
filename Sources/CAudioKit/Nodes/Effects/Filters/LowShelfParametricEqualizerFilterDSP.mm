// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "SoundpipeDSPBase.h"
#include "ParameterRamper.h"
#include "soundpipe.h"

enum LowShelfParametricEqualizerFilterParameter : AUParameterAddress {
    LowShelfParametricEqualizerFilterParameterCornerFrequency,
    LowShelfParametricEqualizerFilterParameterGain,
    LowShelfParametricEqualizerFilterParameterQ,
};

class LowShelfParametricEqualizerFilterDSP : public SoundpipeDSPBase {
private:
    sp_pareq *pareq0;
    sp_pareq *pareq1;
    ParameterRamper cornerFrequencyRamp;
    ParameterRamper gainRamp;
    ParameterRamper qRamp;

public:
    LowShelfParametricEqualizerFilterDSP() {
        parameters[LowShelfParametricEqualizerFilterParameterCornerFrequency] = &cornerFrequencyRamp;
        parameters[LowShelfParametricEqualizerFilterParameterGain] = &gainRamp;
        parameters[LowShelfParametricEqualizerFilterParameterQ] = &qRamp;
    }

    void init(int channelCount, double sampleRate) override {
        SoundpipeDSPBase::init(channelCount, sampleRate);
        sp_pareq_create(&pareq0);
        sp_pareq_init(sp, pareq0);
        sp_pareq_create(&pareq1);
        sp_pareq_init(sp, pareq1);
        pareq0->mode = 1;
        pareq1->mode = 1;
    }

    void deinit() override {
        SoundpipeDSPBase::deinit();
        sp_pareq_destroy(&pareq0);
        sp_pareq_destroy(&pareq1);
    }

    void reset() override {
        SoundpipeDSPBase::reset();
        if (!isInitialized) return;
        sp_pareq_init(sp, pareq0);
        sp_pareq_init(sp, pareq1);
        pareq0->mode = 1;
        pareq1->mode = 1;
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {
        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            int frameOffset = int(frameIndex + bufferOffset);

            float cornerFrequency = cornerFrequencyRamp.getAndStep();
            pareq0->fc = cornerFrequency;
            pareq1->fc = cornerFrequency;

            float gain = gainRamp.getAndStep();
            pareq0->v = gain;
            pareq1->v = gain;

            float q = qRamp.getAndStep();
            pareq0->q = q;
            pareq1->q = q;

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
                    sp_pareq_compute(sp, pareq0, in, out);
                } else {
                    sp_pareq_compute(sp, pareq1, in, out);
                }
            }
        }
    }
};

AK_REGISTER_DSP(LowShelfParametricEqualizerFilterDSP,  "peq1")
AK_REGISTER_PARAMETER(LowShelfParametricEqualizerFilterParameterCornerFrequency)
AK_REGISTER_PARAMETER(LowShelfParametricEqualizerFilterParameterGain)
AK_REGISTER_PARAMETER(LowShelfParametricEqualizerFilterParameterQ)
