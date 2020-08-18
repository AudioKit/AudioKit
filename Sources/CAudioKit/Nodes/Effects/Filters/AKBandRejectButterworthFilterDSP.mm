// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "AKSoundpipeDSPBase.hpp"
#include "ParameterRamper.hpp"
#include "soundpipe.h"

enum AKBandRejectButterworthFilterParameter : AUParameterAddress {
    AKBandRejectButterworthFilterParameterCenterFrequency,
    AKBandRejectButterworthFilterParameterBandwidth,
};

class AKBandRejectButterworthFilterDSP : public AKSoundpipeDSPBase {
private:
    sp_butbr *butbr0;
    sp_butbr *butbr1;
    ParameterRamper centerFrequencyRamp;
    ParameterRamper bandwidthRamp;

public:
    AKBandRejectButterworthFilterDSP() {
        parameters[AKBandRejectButterworthFilterParameterCenterFrequency] = &centerFrequencyRamp;
        parameters[AKBandRejectButterworthFilterParameterBandwidth] = &bandwidthRamp;
    }

    void init(int channelCount, double sampleRate) override {
        AKSoundpipeDSPBase::init(channelCount, sampleRate);
        sp_butbr_create(&butbr0);
        sp_butbr_init(sp, butbr0);
        sp_butbr_create(&butbr1);
        sp_butbr_init(sp, butbr1);
    }

    void deinit() override {
        AKSoundpipeDSPBase::deinit();
        sp_butbr_destroy(&butbr0);
        sp_butbr_destroy(&butbr1);
    }

    void reset() override {
        AKSoundpipeDSPBase::reset();
        if (!isInitialized) return;
        sp_butbr_init(sp, butbr0);
        sp_butbr_init(sp, butbr1);
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {
        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            int frameOffset = int(frameIndex + bufferOffset);

            float centerFrequency = centerFrequencyRamp.getAndStep();
            butbr0->freq = centerFrequency;
            butbr1->freq = centerFrequency;

            float bandwidth = bandwidthRamp.getAndStep();
            butbr0->bw = bandwidth;
            butbr1->bw = bandwidth;

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
                    sp_butbr_compute(sp, butbr0, in, out);
                } else {
                    sp_butbr_compute(sp, butbr1, in, out);
                }
            }
        }
    }
};

AK_REGISTER_DSP(AKBandRejectButterworthFilterDSP)
AK_REGISTER_PARAMETER(AKBandRejectButterworthFilterParameterCenterFrequency)
AK_REGISTER_PARAMETER(AKBandRejectButterworthFilterParameterBandwidth)
