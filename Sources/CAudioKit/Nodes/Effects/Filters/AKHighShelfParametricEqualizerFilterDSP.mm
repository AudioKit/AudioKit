// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "AKSoundpipeDSPBase.hpp"
#include "ParameterRamper.hpp"
#include "soundpipe.h"

enum AKHighShelfParametricEqualizerFilterParameter : AUParameterAddress {
    AKHighShelfParametricEqualizerFilterParameterCenterFrequency,
    AKHighShelfParametricEqualizerFilterParameterGain,
    AKHighShelfParametricEqualizerFilterParameterQ,
};

class AKHighShelfParametricEqualizerFilterDSP : public AKSoundpipeDSPBase {
private:
    sp_pareq *pareq0;
    sp_pareq *pareq1;
    ParameterRamper centerFrequencyRamp;
    ParameterRamper gainRamp;
    ParameterRamper qRamp;

public:
    AKHighShelfParametricEqualizerFilterDSP() {
        parameters[AKHighShelfParametricEqualizerFilterParameterCenterFrequency] = &centerFrequencyRamp;
        parameters[AKHighShelfParametricEqualizerFilterParameterGain] = &gainRamp;
        parameters[AKHighShelfParametricEqualizerFilterParameterQ] = &qRamp;
    }

    void init(int channelCount, double sampleRate) override {
        AKSoundpipeDSPBase::init(channelCount, sampleRate);
        sp_pareq_create(&pareq0);
        sp_pareq_init(sp, pareq0);
        sp_pareq_create(&pareq1);
        sp_pareq_init(sp, pareq1);
        pareq0->mode = 2;
        pareq1->mode = 2;
    }

    void deinit() override {
        AKSoundpipeDSPBase::deinit();
        sp_pareq_destroy(&pareq0);
        sp_pareq_destroy(&pareq1);
    }

    void reset() override {
        AKSoundpipeDSPBase::reset();
        if (!isInitialized) return;
        sp_pareq_init(sp, pareq0);
        sp_pareq_init(sp, pareq1);
        pareq0->mode = 2;
        pareq1->mode = 2;
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {
        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            int frameOffset = int(frameIndex + bufferOffset);

            float centerFrequency = centerFrequencyRamp.getAndStep();
            pareq0->fc = centerFrequency;
            pareq1->fc = centerFrequency;

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

AK_REGISTER_DSP(AKHighShelfParametricEqualizerFilterDSP)
AK_REGISTER_PARAMETER(AKHighShelfParametricEqualizerFilterParameterCenterFrequency)
AK_REGISTER_PARAMETER(AKHighShelfParametricEqualizerFilterParameterGain)
AK_REGISTER_PARAMETER(AKHighShelfParametricEqualizerFilterParameterQ)
