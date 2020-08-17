// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "AKSoundpipeDSPBase.hpp"
#include "ParameterRamper.hpp"
#include "soundpipe.h"

enum AKCombFilterReverbParameter : AUParameterAddress {
    AKCombFilterReverbParameterReverbDuration,
};

class AKCombFilterReverbDSP : public AKSoundpipeDSPBase {
private:
    sp_comb *comb0;
    sp_comb *comb1;
    float loopDuration = 0.1;
    ParameterRamper reverbDurationRamp;

public:
    AKCombFilterReverbDSP() {
        parameters[AKCombFilterReverbParameterReverbDuration] = &reverbDurationRamp;
    }

    void setLoopDuration(float duration) {
        loopDuration = duration;
        reset();
    }

    void init(int channelCount, double sampleRate) override {
        AKSoundpipeDSPBase::init(channelCount, sampleRate);
        sp_comb_create(&comb0);
        sp_comb_init(sp, comb0, loopDuration);
        sp_comb_create(&comb1);
        sp_comb_init(sp, comb1, loopDuration);
    }

    void deinit() override {
        AKSoundpipeDSPBase::deinit();
        sp_comb_destroy(&comb0);
        sp_comb_destroy(&comb1);
    }

    void reset() override {
        AKSoundpipeDSPBase::reset();
        if (!isInitialized) return;
        sp_comb_init(sp, comb0, loopDuration);
        sp_comb_init(sp, comb1, loopDuration);
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {
        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            int frameOffset = int(frameIndex + bufferOffset);

            float reverbDuration = reverbDurationRamp.getAndStep();
            comb0->revtime = reverbDuration;
            comb1->revtime = reverbDuration;

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
                    sp_comb_compute(sp, comb0, in, out);
                } else {
                    sp_comb_compute(sp, comb1, in, out);
                }
            }
        }
    }
};

AK_API void akCombFilterReverbSetLoopDuration(AKDSPRef dspRef, float duration) {
    auto dsp = dynamic_cast<AKCombFilterReverbDSP *>(dspRef);
    assert(dsp);
    dsp->setLoopDuration(duration);
    
}

AK_REGISTER_DSP(AKCombFilterReverbDSP)
AK_REGISTER_PARAMETER(AKCombFilterReverbParameterReverbDuration)
