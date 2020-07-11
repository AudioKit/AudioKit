// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "AKPeakingParametricEqualizerFilterDSP.hpp"
#include "ParameterRamper.hpp"

#import "AKSoundpipeDSPBase.hpp"

class AKPeakingParametricEqualizerFilterDSP : public AKSoundpipeDSPBase {
private:
    sp_pareq *pareq0;
    sp_pareq *pareq1;
    ParameterRamper centerFrequencyRamp;
    ParameterRamper gainRamp;
    ParameterRamper qRamp;

public:
    AKPeakingParametricEqualizerFilterDSP() {
        parameters[AKPeakingParametricEqualizerFilterParameterCenterFrequency] = &centerFrequencyRamp;
        parameters[AKPeakingParametricEqualizerFilterParameterGain] = &gainRamp;
        parameters[AKPeakingParametricEqualizerFilterParameterQ] = &qRamp;
    }

    void init(int channelCount, double sampleRate) {
        AKSoundpipeDSPBase::init(channelCount, sampleRate);
        sp_pareq_create(&pareq0);
        sp_pareq_init(sp, pareq0);
        sp_pareq_create(&pareq1);
        sp_pareq_init(sp, pareq1);
        pareq0->mode = 0;
        pareq1->mode = 0;
    }

    void deinit() {
        AKSoundpipeDSPBase::deinit();
        sp_pareq_destroy(&pareq0);
        sp_pareq_destroy(&pareq1);
    }

    void reset() {
        AKSoundpipeDSPBase::reset();
        if (!isInitialized) return;
        sp_pareq_init(sp, pareq0);
        sp_pareq_init(sp, pareq1);
        pareq0->mode = 0;
        pareq1->mode = 0;
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

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
                    sp_pareq_compute(sp, pareq0, in, out);
                } else {
                    sp_pareq_compute(sp, pareq1, in, out);
                }
            }
        }
    }
};

extern "C" AKDSPRef createPeakingParametricEqualizerFilterDSP() {
    return new AKPeakingParametricEqualizerFilterDSP();
}
