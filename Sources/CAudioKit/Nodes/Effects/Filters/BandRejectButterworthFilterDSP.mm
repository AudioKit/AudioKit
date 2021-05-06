// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "SoundpipeDSPBase.h"
#include "ParameterRamper.h"
#include "soundpipe.h"

enum BandRejectButterworthFilterParameter : AUParameterAddress {
    BandRejectButterworthFilterParameterCenterFrequency,
    BandRejectButterworthFilterParameterBandwidth,
};

class BandRejectButterworthFilterDSP : public SoundpipeDSPBase {
private:
    sp_butbr *butbr0;
    sp_butbr *butbr1;
    ParameterRamper centerFrequencyRamp;
    ParameterRamper bandwidthRamp;

public:
    BandRejectButterworthFilterDSP() {
        parameters[BandRejectButterworthFilterParameterCenterFrequency] = &centerFrequencyRamp;
        parameters[BandRejectButterworthFilterParameterBandwidth] = &bandwidthRamp;
    }

    void init(int channelCount, double sampleRate) override {
        SoundpipeDSPBase::init(channelCount, sampleRate);
        sp_butbr_create(&butbr0);
        sp_butbr_init(sp, butbr0);
        sp_butbr_create(&butbr1);
        sp_butbr_init(sp, butbr1);
    }

    void deinit() override {
        SoundpipeDSPBase::deinit();
        sp_butbr_destroy(&butbr0);
        sp_butbr_destroy(&butbr1);
    }

    void reset() override {
        SoundpipeDSPBase::reset();
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

AK_REGISTER_DSP(BandRejectButterworthFilterDSP, "btbr")
AK_REGISTER_PARAMETER(BandRejectButterworthFilterParameterCenterFrequency)
AK_REGISTER_PARAMETER(BandRejectButterworthFilterParameterBandwidth)
