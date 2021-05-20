// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "SoundpipeDSPBase.h"
#include "ParameterRamper.h"
#include "Soundpipe.h"

class DCBlockDSP : public SoundpipeDSPBase {
private:
    sp_dcblock *dcblock0;
    sp_dcblock *dcblock1;

public:
    DCBlockDSP() {
    }

    void init(int channelCount, double sampleRate) override {
        SoundpipeDSPBase::init(channelCount, sampleRate);
        sp_dcblock_create(&dcblock0);
        sp_dcblock_init(sp, dcblock0);
        sp_dcblock_create(&dcblock1);
        sp_dcblock_init(sp, dcblock1);
    }

    void deinit() override {
        SoundpipeDSPBase::deinit();
        sp_dcblock_destroy(&dcblock0);
        sp_dcblock_destroy(&dcblock1);
    }

    void reset() override {
        SoundpipeDSPBase::reset();
        if (!isInitialized) return;
        sp_dcblock_init(sp, dcblock0);
        sp_dcblock_init(sp, dcblock1);
    }

    void process(FrameRange range) override {
        for (int i : range) {

            float leftIn = inputSample(0, i);
            float rightIn = inputSample(1, i);

            float &leftOut = outputSample(0, i);
            float &rightOut = outputSample(1, i);

            sp_dcblock_compute(sp, dcblock0, &leftIn, &leftOut);
            sp_dcblock_compute(sp, dcblock1, &rightIn, &rightOut);
        }
    }
};

AK_REGISTER_DSP(DCBlockDSP, "dcbk")
