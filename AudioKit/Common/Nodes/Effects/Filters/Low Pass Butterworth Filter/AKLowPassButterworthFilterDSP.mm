// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "AKLowPassButterworthFilterDSP.hpp"
#include "ParameterRamper.hpp"

#import "AKSoundpipeDSPBase.hpp"

class AKLowPassButterworthFilterDSP : public AKSoundpipeDSPBase {
private:
    sp_butlp *butlp0;
    sp_butlp *butlp1;
    ParameterRamper cutoffFrequencyRamp;

public:
    AKLowPassButterworthFilterDSP() {
        parameters[AKLowPassButterworthFilterParameterCutoffFrequency] = &cutoffFrequencyRamp;
    }

    void init(int channelCount, double sampleRate) {
        AKSoundpipeDSPBase::init(channelCount, sampleRate);
        sp_butlp_create(&butlp0);
        sp_butlp_init(sp, butlp0);
        sp_butlp_create(&butlp1);
        sp_butlp_init(sp, butlp1);
    }

    void deinit() {
        AKSoundpipeDSPBase::deinit();
        sp_butlp_destroy(&butlp0);
        sp_butlp_destroy(&butlp1);
    }

    void reset() {
        AKSoundpipeDSPBase::reset();
        if (!isInitialized) return;
        sp_butlp_init(sp, butlp0);
        sp_butlp_init(sp, butlp1);
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            int frameOffset = int(frameIndex + bufferOffset);

            float cutoffFrequency = cutoffFrequencyRamp.getAndStep();
            butlp0->freq = cutoffFrequency;
            butlp1->freq = cutoffFrequency;

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
                    sp_butlp_compute(sp, butlp0, in, out);
                } else {
                    sp_butlp_compute(sp, butlp1, in, out);
                }
            }
        }
    }
};

extern "C" AKDSPRef createLowPassButterworthFilterDSP() {
    return new AKLowPassButterworthFilterDSP();
}