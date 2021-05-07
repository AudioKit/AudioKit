// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "SoundpipeDSPBase.h"
#include "ParameterRamper.h"
#include "soundpipe.h"

enum StringResonatorParameter : AUParameterAddress {
    StringResonatorParameterFundamentalFrequency,
    StringResonatorParameterFeedback,
};

class StringResonatorDSP : public SoundpipeDSPBase {
private:
    sp_streson *streson0;
    sp_streson *streson1;
    ParameterRamper fundamentalFrequencyRamp;
    ParameterRamper feedbackRamp;

public:
    StringResonatorDSP() {
        parameters[StringResonatorParameterFundamentalFrequency] = &fundamentalFrequencyRamp;
        parameters[StringResonatorParameterFeedback] = &feedbackRamp;
    }

    void init(int channelCount, double sampleRate) override {
        SoundpipeDSPBase::init(channelCount, sampleRate);
        sp_streson_create(&streson0);
        sp_streson_init(sp, streson0);
        sp_streson_create(&streson1);
        sp_streson_init(sp, streson1);
    }

    void deinit() override {
        SoundpipeDSPBase::deinit();
        sp_streson_destroy(&streson0);
        sp_streson_destroy(&streson1);
    }

    void reset() override {
        SoundpipeDSPBase::reset();
        if (!isInitialized) return;
        sp_streson_init(sp, streson0);
        sp_streson_init(sp, streson1);
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {
        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            int frameOffset = int(frameIndex + bufferOffset);

            float fundamentalFrequency = fundamentalFrequencyRamp.getAndStep();
            streson0->freq = fundamentalFrequency;
            streson1->freq = fundamentalFrequency;

            float feedback = feedbackRamp.getAndStep();
            streson0->fdbgain = feedback;
            streson1->fdbgain = feedback;

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
                    sp_streson_compute(sp, streson0, in, out);
                } else {
                    sp_streson_compute(sp, streson1, in, out);
                }
            }
        }
    }
};

AK_REGISTER_DSP(StringResonatorDSP, "stre")
AK_REGISTER_PARAMETER(StringResonatorParameterFundamentalFrequency)
AK_REGISTER_PARAMETER(StringResonatorParameterFeedback)
