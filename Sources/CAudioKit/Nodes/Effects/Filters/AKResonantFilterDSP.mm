// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "AKSoundpipeDSPBase.hpp"
#include "ParameterRamper.hpp"
#include "soundpipe.h"

enum AKResonantFilterParameter : AUParameterAddress {
    AKResonantFilterParameterFrequency,
    AKResonantFilterParameterBandwidth,
};

class AKResonantFilterDSP : public AKSoundpipeDSPBase {
private:
    sp_reson *reson0;
    sp_reson *reson1;
    ParameterRamper frequencyRamp;
    ParameterRamper bandwidthRamp;

public:
    AKResonantFilterDSP() {
        parameters[AKResonantFilterParameterFrequency] = &frequencyRamp;
        parameters[AKResonantFilterParameterBandwidth] = &bandwidthRamp;
    }

    void init(int channelCount, double sampleRate) override {
        AKSoundpipeDSPBase::init(channelCount, sampleRate);
        sp_reson_create(&reson0);
        sp_reson_init(sp, reson0);
        sp_reson_create(&reson1);
        sp_reson_init(sp, reson1);
    }

    void deinit() override {
        AKSoundpipeDSPBase::deinit();
        sp_reson_destroy(&reson0);
        sp_reson_destroy(&reson1);
    }

    void reset() override {
        AKSoundpipeDSPBase::reset();
        if (!isInitialized) return;
        sp_reson_init(sp, reson0);
        sp_reson_init(sp, reson1);
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {
        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            int frameOffset = int(frameIndex + bufferOffset);

            float frequency = frequencyRamp.getAndStep();
            reson0->freq = frequency;
            reson1->freq = frequency;

            float bandwidth = bandwidthRamp.getAndStep();
            reson0->bw = bandwidth;
            reson1->bw = bandwidth;

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
                    sp_reson_compute(sp, reson0, in, out);
                } else {
                    sp_reson_compute(sp, reson1, in, out);
                }
            }
        }
    }
};

AK_REGISTER_DSP(AKResonantFilterDSP)
AK_REGISTER_PARAMETER(AKResonantFilterParameterFrequency)
AK_REGISTER_PARAMETER(AKResonantFilterParameterBandwidth)
