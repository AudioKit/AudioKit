// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "AKBandPassButterworthFilterDSP.hpp"
#include "ParameterRamper.hpp"

#import "AKSoundpipeDSPBase.hpp"

class AKBandPassButterworthFilterDSP : public AKSoundpipeDSPBase {
private:
    sp_butbp *butbp0;
    sp_butbp *butbp1;
    ParameterRamper centerFrequencyRamp;
    ParameterRamper bandwidthRamp;

public:
    AKBandPassButterworthFilterDSP() {
        parameters[AKBandPassButterworthFilterParameterCenterFrequency] = &centerFrequencyRamp;
        parameters[AKBandPassButterworthFilterParameterBandwidth] = &bandwidthRamp;
    }

    void init(int channelCount, double sampleRate) {
        AKSoundpipeDSPBase::init(channelCount, sampleRate);
        sp_butbp_create(&butbp0);
        sp_butbp_init(sp, butbp0);
        sp_butbp_create(&butbp1);
        sp_butbp_init(sp, butbp1);
    }

    void deinit() {
        AKSoundpipeDSPBase::deinit();
        sp_butbp_destroy(&butbp0);
        sp_butbp_destroy(&butbp1);
    }

    void reset() {
        AKSoundpipeDSPBase::reset();
        if (!isInitialized) return;
        sp_butbp_init(sp, butbp0);
        sp_butbp_init(sp, butbp1);
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            int frameOffset = int(frameIndex + bufferOffset);

            float centerFrequency = centerFrequencyRamp.getAndStep();
            butbp0->freq = centerFrequency;
            butbp1->freq = centerFrequency;

            float bandwidth = bandwidthRamp.getAndStep();
            butbp0->bw = bandwidth;
            butbp1->bw = bandwidth;

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
                    sp_butbp_compute(sp, butbp0, in, out);
                } else {
                    sp_butbp_compute(sp, butbp1, in, out);
                }
            }
        }
    }
};

extern "C" AKDSPRef createBandPassButterworthFilterDSP() {
    return new AKBandPassButterworthFilterDSP();
}