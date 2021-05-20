// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "SoundpipeDSPBase.h"
#include "ParameterRamper.h"
#include "Soundpipe.h"

class ChowningReverbDSP : public SoundpipeDSPBase {
private:
    sp_jcrev *jcrev0;
    sp_jcrev *jcrev1;

public:
    ChowningReverbDSP() {
    }

    void init(int channelCount, double sampleRate) override {
        SoundpipeDSPBase::init(channelCount, sampleRate);
        sp_jcrev_create(&jcrev0);
        sp_jcrev_init(sp, jcrev0);
        sp_jcrev_create(&jcrev1);
        sp_jcrev_init(sp, jcrev1);
    }

    void deinit() override {
        SoundpipeDSPBase::deinit();
        sp_jcrev_destroy(&jcrev0);
        sp_jcrev_destroy(&jcrev1);
    }

    void reset() override {
        SoundpipeDSPBase::reset();
        if (!isInitialized) return;
        sp_jcrev_init(sp, jcrev0);
        sp_jcrev_init(sp, jcrev1);
    }

    void process(FrameRange range) override {
        for (int i : range) {

            float leftIn = inputSample(0, i);
            float rightIn = inputSample(1, i);

            float &leftOut = outputSample(0, i);
            float &rightOut = outputSample(1, i);

            sp_jcrev_compute(sp, jcrev0, &leftIn, &leftOut);
            sp_jcrev_compute(sp, jcrev1, &rightIn, &rightOut);
        }
    }
};

AK_REGISTER_DSP(ChowningReverbDSP, "jcrv")
