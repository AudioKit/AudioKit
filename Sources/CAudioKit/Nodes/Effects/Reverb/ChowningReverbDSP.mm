// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "SoundpipeDSPBase.h"
#include "ParameterRamper.h"
#include "soundpipe.h"

class ChowningReverbDSP : public SoundpipeDSPBase {
private:
    sp_jcrev *jcrev0;
    sp_jcrev *jcrev1;

public:
    ChowningReverbDSP() {
    }

    void init(int channelCount, double sampleRate) override {
        SoundpipeDSPBase::init(channelCount, sampleRate);
        sp_jcrev_create(&jcrev0);
        sp_jcrev_init(sp, jcrev0);
        sp_jcrev_create(&jcrev1);
        sp_jcrev_init(sp, jcrev1);
    }

    void deinit() override {
        SoundpipeDSPBase::deinit();
        sp_jcrev_destroy(&jcrev0);
        sp_jcrev_destroy(&jcrev1);
    }

    void reset() override {
        SoundpipeDSPBase::reset();
        if (!isInitialized) return;
        sp_jcrev_init(sp, jcrev0);
        sp_jcrev_init(sp, jcrev1);
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {
        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            int frameOffset = int(frameIndex + bufferOffset);

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
                    sp_jcrev_compute(sp, jcrev0, in, out);
                } else {
                    sp_jcrev_compute(sp, jcrev1, in, out);
                }
            }
        }
    }
};

AK_REGISTER_DSP(ChowningReverbDSP, "jcrv")
