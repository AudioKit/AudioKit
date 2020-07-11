// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "AKCostelloReverbDSP.hpp"
#include "ParameterRamper.hpp"

#import "AKSoundpipeDSPBase.hpp"

class AKCostelloReverbDSP : public AKSoundpipeDSPBase {
private:
    sp_revsc *revsc;
    ParameterRamper feedbackRamp;
    ParameterRamper cutoffFrequencyRamp;

public:
    AKCostelloReverbDSP() {
        parameters[AKCostelloReverbParameterFeedback] = &feedbackRamp;
        parameters[AKCostelloReverbParameterCutoffFrequency] = &cutoffFrequencyRamp;
    }

    void init(int channelCount, double sampleRate) {
        AKSoundpipeDSPBase::init(channelCount, sampleRate);
        sp_revsc_create(&revsc);
        sp_revsc_init(sp, revsc);
    }

    void deinit() {
        AKSoundpipeDSPBase::deinit();
        sp_revsc_destroy(&revsc);
    }

    void reset() {
        AKSoundpipeDSPBase::reset();
        if (!isInitialized) return;
        sp_revsc_init(sp, revsc);
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            int frameOffset = int(frameIndex + bufferOffset);

            revsc->feedback = feedbackRamp.getAndStep();

            revsc->lpfreq = cutoffFrequencyRamp.getAndStep();

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
            
            }
            if (isStarted) {
                sp_revsc_compute(sp, revsc, tmpin[0], tmpin[1], tmpout[0], tmpout[1]);
            }
        }
    }
};

extern "C" AKDSPRef createCostelloReverbDSP() {
    return new AKCostelloReverbDSP();
}