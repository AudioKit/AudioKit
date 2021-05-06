// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "SoundpipeDSPBase.h"
#include "ParameterRamper.h"
#include "soundpipe.h"

enum CostelloReverbParameter : AUParameterAddress {
    CostelloReverbParameterFeedback,
    CostelloReverbParameterCutoffFrequency,
};

class CostelloReverbDSP : public SoundpipeDSPBase {
private:
    sp_revsc *revsc;
    ParameterRamper feedbackRamp;
    ParameterRamper cutoffFrequencyRamp;

public:
    CostelloReverbDSP() {
        parameters[CostelloReverbParameterFeedback] = &feedbackRamp;
        parameters[CostelloReverbParameterCutoffFrequency] = &cutoffFrequencyRamp;
    }

    void init(int channelCount, double sampleRate) override {
        SoundpipeDSPBase::init(channelCount, sampleRate);
        sp_revsc_create(&revsc);
        sp_revsc_init(sp, revsc);
    }

    void deinit() override {
        SoundpipeDSPBase::deinit();
        sp_revsc_destroy(&revsc);
    }

    void reset() override {
        SoundpipeDSPBase::reset();
        if (!isInitialized) return;
        sp_revsc_init(sp, revsc);
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {
        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            int frameOffset = int(frameIndex + bufferOffset);

            revsc->feedback = feedbackRamp.getAndStep();

            revsc->lpfreq = cutoffFrequencyRamp.getAndStep();

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
            
            }
            if (isStarted) {
                sp_revsc_compute(sp, revsc, tmpin[0], tmpin[1], tmpout[0], tmpout[1]);
            }
        }
    }
};

AK_REGISTER_DSP(CostelloReverbDSP, "rvsc")
AK_REGISTER_PARAMETER(CostelloReverbParameterFeedback)
AK_REGISTER_PARAMETER(CostelloReverbParameterCutoffFrequency)
