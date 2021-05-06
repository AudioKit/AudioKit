// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "SoundpipeDSPBase.h"
#include "ParameterRamper.h"
#include "soundpipe.h"

class BalancerDSP : public SoundpipeDSPBase {
private:
    sp_bal *bal;

public:
    BalancerDSP() {
        inputBufferLists.resize(2);
    }

    void init(int channelCount, double sampleRate) override {
        SoundpipeDSPBase::init(channelCount, sampleRate);

        sp_bal_create(&bal);
        sp_bal_init(sp, bal);
    }

    void deinit() override {
        SoundpipeDSPBase::deinit();
        sp_bal_destroy(&bal);
    }

    void reset() override {
        SoundpipeDSPBase::reset();
        if (isInitialized) sp_bal_init(sp, bal);
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {
        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            int frameOffset = int(frameIndex + bufferOffset);

            for (int channel = 0; channel < channelCount; ++channel) {
                float *in   = (float *)inputBufferLists[0]->mBuffers[channel].mData  + frameOffset;
                float *comp = (float *)inputBufferLists[1]->mBuffers[channel].mData + frameOffset;
                float *out  = (float *)outputBufferList->mBuffers[channel].mData + frameOffset;

                if (isStarted) {
                    sp_bal_compute(sp, bal, in, comp, out);
                } else {
                    *out = *in;
                }
            }
        }
    }
};

AK_REGISTER_DSP(BalancerDSP, "blnc")
