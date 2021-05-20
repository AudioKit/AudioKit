// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "SoundpipeDSPBase.h"
#include "ParameterRamper.h"
#include "Soundpipe.h"

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

    void process(FrameRange range) override {
        for (int i : range) {

            panst->pan = panRamp.getAndStep();

            float leftIn = inputSample(0, i);
            float rightIn = inputSample(1, i);

            float &leftOut = outputSample(0, i);
            float &rightOut = outputSample(1, i);
            
            sp_panst_compute(sp, panst, &leftIn, &rightIn, &leftOut, &rightOut);
        }
    }
};

AK_REGISTER_DSP(PannerDSP, "pan2")
AK_REGISTER_PARAMETER(PannerParameterPan)
