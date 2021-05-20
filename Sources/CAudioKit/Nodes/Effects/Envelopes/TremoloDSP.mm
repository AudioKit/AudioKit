// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "SoundpipeDSPBase.h"
#include "ParameterRamper.h"
#include "Soundpipe.h"
#include <vector>

enum TremoloParameter : AUParameterAddress {
    TremoloParameterFrequency,
    TremoloParameterDepth,
};

class TremoloDSP : public SoundpipeDSPBase {
private:
    sp_osc *trem;
    sp_ftbl *ftbl;
    std::vector<float> wavetable;
    ParameterRamper frequencyRamp;
    ParameterRamper depthRamp;

public:
    TremoloDSP() {
        parameters[TremoloParameterFrequency] = &frequencyRamp;
        parameters[TremoloParameterDepth] = &depthRamp;
    }

    void init(int channelCount, double sampleRate) override {
        SoundpipeDSPBase::init(channelCount, sampleRate);
        sp_ftbl_create(sp, &ftbl, wavetable.size());
        std::copy(wavetable.cbegin(), wavetable.cend(), ftbl->tbl);
        sp_osc_create(&trem);
        sp_osc_init(sp, trem, ftbl, 0);
    }

    void setWavetable(const float* table, size_t length, int index) override {
        wavetable = std::vector<float>(table, table + length);
        reset();
    }

    void deinit() override {
        SoundpipeDSPBase::deinit();
        sp_osc_destroy(&trem);
        sp_ftbl_destroy(&ftbl);
    }

    void reset() override {
        SoundpipeDSPBase::reset();
        if (!isInitialized) return;
        sp_osc_init(sp, trem, ftbl, 0);
    }

    void process(FrameRange range) override {

        for (int i : range) {
            trem->freq = frequencyRamp.getAndStep();
            trem->amp = depthRamp.getAndStep();
            
            float temp = 0;
            sp_osc_compute(sp, trem, NULL, &temp);
            outputSample(0, i) = inputSample(0, i) * (1.0 - temp);
            outputSample(1, i) = inputSample(1, i) * (1.0 - temp);
        }
    }
};

AK_REGISTER_DSP(TremoloDSP, "trem")
AK_REGISTER_PARAMETER(TremoloParameterFrequency)
AK_REGISTER_PARAMETER(TremoloParameterDepth)
