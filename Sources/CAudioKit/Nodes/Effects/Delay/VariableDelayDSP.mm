// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "SoundpipeDSPBase.h"
#include "ParameterRamper.h"
#include "soundpipe.h"

enum VariableDelayParameter : AUParameterAddress {
    VariableDelayParameterTime,
    VariableDelayParameterFeedback,
};

class VariableDelayDSP : public SoundpipeDSPBase {
private:
    sp_vdelay *vdelay0;
    sp_vdelay *vdelay1;
    float maximumTime = 10.0;
    ParameterRamper timeRamp;
    ParameterRamper feedbackRamp;

public:
    VariableDelayDSP() : SoundpipeDSPBase(1, false) {
        parameters[VariableDelayParameterTime] = &timeRamp;
        parameters[VariableDelayParameterFeedback] = &feedbackRamp;
    }

    void setMaximumTime(float maxTime) {
        maximumTime = maxTime;
        reset();
    }


    void init(int channelCount, double sampleRate) override {
        SoundpipeDSPBase::init(channelCount, sampleRate);
        sp_vdelay_create(&vdelay0);
        sp_vdelay_init(sp, vdelay0, maximumTime);
        sp_vdelay_create(&vdelay1);
        sp_vdelay_init(sp, vdelay1, maximumTime);
    }

    void deinit() override {
        SoundpipeDSPBase::deinit();
        sp_vdelay_destroy(&vdelay0);
        sp_vdelay_destroy(&vdelay1);
    }

    void reset() override {
        SoundpipeDSPBase::reset();
        if (!isInitialized) return;
        sp_vdelay_init(sp, vdelay0, maximumTime);
        sp_vdelay_init(sp, vdelay1, maximumTime);
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {
        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            int frameOffset = int(frameIndex + bufferOffset);

            float time = timeRamp.getAndStep();
            if (time > maximumTime) time = maximumTime;
            vdelay0->del = time;
            vdelay1->del = time;

            float feedback = feedbackRamp.getAndStep();
            vdelay0->feedback = feedback;
            vdelay1->feedback = feedback;

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
                    sp_vdelay_compute(sp, vdelay0, in, out);
                } else {
                    sp_vdelay_compute(sp, vdelay1, in, out);
                }
            }
        }
    }
};

AK_API void akVariableDelaySetMaximumTime(DSPRef dspRef, float maximumTime) {
    auto dsp = dynamic_cast<VariableDelayDSP *>(dspRef);
    assert(dsp);
    dsp->setMaximumTime(maximumTime);
}

AK_REGISTER_DSP(VariableDelayDSP, "vdla")
AK_REGISTER_PARAMETER(VariableDelayParameterTime)
AK_REGISTER_PARAMETER(VariableDelayParameterFeedback)
