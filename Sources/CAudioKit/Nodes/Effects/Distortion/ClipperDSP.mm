// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "SoundpipeDSPBase.h"
#include "ParameterRamper.h"
#include "soundpipe.h"

enum ClipperParameter : AUParameterAddress {
    ClipperParameterLimit,
};

class ClipperDSP : public SoundpipeDSPBase {
private:
    sp_clip *clip0;
    sp_clip *clip1;
    ParameterRamper limitRamp;

public:
    ClipperDSP() {
        parameters[ClipperParameterLimit] = &limitRamp;
    }

    void init(int channelCount, double sampleRate) override {
        SoundpipeDSPBase::init(channelCount, sampleRate);
        sp_clip_create(&clip0);
        sp_clip_init(sp, clip0);
        sp_clip_create(&clip1);
        sp_clip_init(sp, clip1);
    }

    void deinit() override {
        SoundpipeDSPBase::deinit();
        sp_clip_destroy(&clip0);
        sp_clip_destroy(&clip1);
    }

    void reset() override {
        SoundpipeDSPBase::reset();
        if (!isInitialized) return;
        sp_clip_init(sp, clip0);
        sp_clip_init(sp, clip1);
    }

    void process2(FrameRange range) override {
        for (int i : range) {

            float limit = limitRamp.getAndStep();
            clip0->lim = limit;
            clip1->lim = limit;

            float leftIn = inputSample(0, i);
            float rightIn = inputSample(1, i);

            float &leftOut = outputSample(0, i);
            float &rightOut = outputSample(1, i);

            sp_clip_compute(sp, clip0, &leftIn, &leftOut);
            sp_clip_compute(sp, clip1, &rightIn, &rightOut);
        }
    }
};

AK_REGISTER_DSP(ClipperDSP, "clip")
AK_REGISTER_PARAMETER(ClipperParameterLimit)
