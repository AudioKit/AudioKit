// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "SoundpipeDSPBase.h"
#include "ParameterRamper.h"
#include "soundpipe.h"

enum PannerParameter : AUParameterAddress {
    PannerParameterPan,
};

class PannerDSP : public SoundpipeDSPBase {
private:
    sp_panst *panst;
    ParameterRamper panRamp;

public:
    PannerDSP() {
        parameters[PannerParameterPan] = &panRamp;
    }

    void init(int channelCount, double sampleRate) override {
        SoundpipeDSPBase::init(channelCount, sampleRate);
        sp_panst_create(&panst);
        sp_panst_init(sp, panst);
    }

    void deinit() override {
        SoundpipeDSPBase::deinit();
        sp_panst_destroy(&panst);
    }

    void reset() override {
        SoundpipeDSPBase::reset();
        if (!isInitialized) return;
        sp_panst_init(sp, panst);
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {
        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            int frameOffset = int(frameIndex + bufferOffset);

            panst->pan = panRamp.getAndStep();

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
            
            }
            if (isStarted) {
                sp_panst_compute(sp, panst, tmpin[0], tmpin[1], tmpout[0], tmpout[1]);
            }
        }
    }
};

AK_REGISTER_DSP(PannerDSP, "pan2")
AK_REGISTER_PARAMETER(PannerParameterPan)
