// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "AKSoundpipeDSPBase.hpp"
#include "ParameterRamper.hpp"
#include "soundpipe.h"

enum AKMoogLadderParameter : AUParameterAddress {
    AKMoogLadderParameterCutoffFrequency,
    AKMoogLadderParameterResonance,
};

class AKMoogLadderDSP : public AKSoundpipeDSPBase {
private:
    sp_moogladder *moogladder0;
    sp_moogladder *moogladder1;
    ParameterRamper cutoffFrequencyRamp;
    ParameterRamper resonanceRamp;

public:
    AKMoogLadderDSP() {
        parameters[AKMoogLadderParameterCutoffFrequency] = &cutoffFrequencyRamp;
        parameters[AKMoogLadderParameterResonance] = &resonanceRamp;
    }

    void init(int channelCount, double sampleRate) override {
        AKSoundpipeDSPBase::init(channelCount, sampleRate);
        sp_moogladder_create(&moogladder0);
        sp_moogladder_init(sp, moogladder0);
        sp_moogladder_create(&moogladder1);
        sp_moogladder_init(sp, moogladder1);
    }

    void deinit() override {
        AKSoundpipeDSPBase::deinit();
        sp_moogladder_destroy(&moogladder0);
        sp_moogladder_destroy(&moogladder1);
    }

    void reset() override {
        AKSoundpipeDSPBase::reset();
        if (!isInitialized) return;
        sp_moogladder_init(sp, moogladder0);
        sp_moogladder_init(sp, moogladder1);
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {
        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            int frameOffset = int(frameIndex + bufferOffset);

            float cutoffFrequency = cutoffFrequencyRamp.getAndStep();
            moogladder0->freq = cutoffFrequency;
            moogladder1->freq = cutoffFrequency;

            float resonance = resonanceRamp.getAndStep();
            moogladder0->res = resonance;
            moogladder1->res = resonance;

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
                    sp_moogladder_compute(sp, moogladder0, in, out);
                } else {
                    sp_moogladder_compute(sp, moogladder1, in, out);
                }
            }
        }
    }
};

AK_REGISTER_DSP(AKMoogLadderDSP)
AK_REGISTER_PARAMETER(AKMoogLadderParameterCutoffFrequency)
AK_REGISTER_PARAMETER(AKMoogLadderParameterResonance)
