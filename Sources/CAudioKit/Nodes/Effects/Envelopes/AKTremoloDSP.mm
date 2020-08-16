// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "AKSoundpipeDSPBase.hpp"
#include "ParameterRamper.hpp"
#include "soundpipe.h"
#include <vector>

enum AKTremoloParameter : AUParameterAddress {
    AKTremoloParameterFrequency,
    AKTremoloParameterDepth,
};

class AKTremoloDSP : public AKSoundpipeDSPBase {
private:
    sp_osc *trem;
    sp_ftbl *ftbl;
    std::vector<float> wavetable;
    ParameterRamper frequencyRamp;
    ParameterRamper depthRamp;

public:
    AKTremoloDSP() {
        parameters[AKTremoloParameterFrequency] = &frequencyRamp;
        parameters[AKTremoloParameterDepth] = &depthRamp;
    }

    void init(int channelCount, double sampleRate) override {
        AKSoundpipeDSPBase::init(channelCount, sampleRate);
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
        AKSoundpipeDSPBase::deinit();
        sp_osc_destroy(&trem);
        sp_ftbl_destroy(&ftbl);
    }

    void reset() override {
        AKSoundpipeDSPBase::reset();
        if (!isInitialized) return;
        sp_osc_init(sp, trem, ftbl, 0);
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {
        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            int frameOffset = int(frameIndex + bufferOffset);

            trem->freq = frequencyRamp.getAndStep() * 0.5;
            trem->amp = depthRamp.getAndStep();

            float temp = 0;
            for (int channel = 0; channel < channelCount; ++channel) {
                float *in  = (float *)inputBufferLists[0]->mBuffers[channel].mData  + frameOffset;
                float *out = (float *)outputBufferList->mBuffers[channel].mData + frameOffset;

                if (isStarted) {
                    sp_osc_compute(sp, trem, NULL, &temp);
                    *out = *in * (1.0 - temp);
                } else {
                    *out = *in;
                }
            }
        }
    }
};

AK_REGISTER_DSP(AKTremoloDSP)
AK_REGISTER_PARAMETER(AKTremoloParameterFrequency)
AK_REGISTER_PARAMETER(AKTremoloParameterDepth)
