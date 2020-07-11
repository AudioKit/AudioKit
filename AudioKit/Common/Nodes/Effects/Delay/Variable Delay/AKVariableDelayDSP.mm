// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "AKVariableDelayDSP.hpp"
#include "ParameterRamper.hpp"

#import "AKSoundpipeDSPBase.hpp"

class AKVariableDelayDSP : public AKSoundpipeDSPBase {
private:
    sp_vdelay *vdelay0;
    sp_vdelay *vdelay1;
    ParameterRamper timeRamp;
    ParameterRamper feedbackRamp;

public:
    AKVariableDelayDSP() {
        parameters[AKVariableDelayParameterTime] = &timeRamp;
        parameters[AKVariableDelayParameterFeedback] = &feedbackRamp;
        bCanProcessInPlace = false;
    }

    void init(int channelCount, double sampleRate) {
        AKSoundpipeDSPBase::init(channelCount, sampleRate);
        sp_vdelay_create(&vdelay0);
        sp_vdelay_init(sp, vdelay0, 10);
        sp_vdelay_create(&vdelay1);
        sp_vdelay_init(sp, vdelay1, 10);
    }

    void deinit() {
        AKSoundpipeDSPBase::deinit();
        sp_vdelay_destroy(&vdelay0);
        sp_vdelay_destroy(&vdelay1);
    }

    void reset() {
        AKSoundpipeDSPBase::reset();
        if (!isInitialized) return;
        sp_vdelay_init(sp, vdelay0, 10);
        sp_vdelay_init(sp, vdelay1, 10);
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            int frameOffset = int(frameIndex + bufferOffset);

            float time = timeRamp.getAndStep();
            vdelay0->del = time;
            vdelay1->del = time;

            float feedback = feedbackRamp.getAndStep();
            vdelay0->feedback = feedback;
            vdelay1->feedback = feedback;

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
                    sp_vdelay_compute(sp, vdelay0, in, out);
                } else {
                    sp_vdelay_compute(sp, vdelay1, in, out);
                }
            }
        }
    }
};

extern "C" AKDSPRef createVariableDelayDSP() {
    return new AKVariableDelayDSP();
}
