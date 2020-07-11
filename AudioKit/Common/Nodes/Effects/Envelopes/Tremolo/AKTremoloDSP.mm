// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "AKTremoloDSP.hpp"
#include "ParameterRamper.hpp"
#include <vector>

#import "AKSoundpipeDSPBase.hpp"

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

    void init(int channelCount, double sampleRate) {
        AKSoundpipeDSPBase::init(channelCount, sampleRate);
        sp_ftbl_create(sp, &ftbl, wavetable.size());
        std::copy(wavetable.cbegin(), wavetable.cend(), ftbl->tbl);
        sp_osc_create(&trem);
        sp_osc_init(sp, trem, ftbl, 0);
    }

    void setWavetable(const float* table, size_t length, int index) {
        wavetable = std::vector<float>(table, table + length);
        reset();
    }

    void deinit() {
        AKSoundpipeDSPBase::deinit();
        sp_osc_destroy(&trem);
        sp_ftbl_destroy(&ftbl);
    }

    void reset() {
        AKSoundpipeDSPBase::reset();
        if (!isInitialized) return;
        sp_osc_init(sp, trem, ftbl, 0);
    }


    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            int frameOffset = int(frameIndex + bufferOffset);

            trem->freq = frequencyRamp.getAndStep() * 0.5;
            trem->amp = depthRamp.getAndStep();

            float temp = 0;
            for (int channel = 0; channel < channelCount; ++channel) {
                float *in  = (float *)inputBufferLists[0]->mBuffers[channel].mData  + frameOffset;
                float *out = (float *)outputBufferLists[0]->mBuffers[channel].mData + frameOffset;

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

extern "C" AKDSPRef createTremoloDSP() {
    return new AKTremoloDSP();
}
