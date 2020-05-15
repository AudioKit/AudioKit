//
//  AKTremoloDSP.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2020 AudioKit. All rights reserved.
//

#include "AKTremoloDSP.hpp"
#include "AKLinearParameterRamp.hpp"
#include <vector>

extern "C" AKDSPRef createTremoloDSP() {
    return new AKTremoloDSP();
}

struct AKTremoloDSP::InternalData {
    sp_osc *trem;
    sp_ftbl *ftbl;
    std::vector<float> wavetable;
    AKLinearParameterRamp frequencyRamp;
    AKLinearParameterRamp depthRamp;
};

AKTremoloDSP::AKTremoloDSP() : data(new InternalData) {
    parameters[AKTremoloParameterFrequency] = &data->frequencyRamp;
    parameters[AKTremoloParameterDepth] = &data->depthRamp;
}

void AKTremoloDSP::setWavetable(const float* table, size_t length, int index) {
    data->wavetable = std::vector<float>(table, table + length);
    reset();
}

void AKTremoloDSP::init(int channelCount, double sampleRate) {
    AKSoundpipeDSPBase::init(channelCount, sampleRate);
    sp_ftbl_create(sp, &data->ftbl, data->wavetable.size());
    std::copy(data->wavetable.cbegin(), data->wavetable.cend(), data->ftbl->tbl);
    sp_osc_create(&data->trem);
    sp_osc_init(sp, data->trem, data->ftbl, 0);
}

void AKTremoloDSP::deinit() {
    AKSoundpipeDSPBase::deinit();
    sp_osc_destroy(&data->trem);
    sp_ftbl_destroy(&data->ftbl);
}

void AKTremoloDSP::reset() {
    AKSoundpipeDSPBase::reset();
    if (!isInitialized) return;
    sp_osc_init(sp, data->trem, data->ftbl, 0);
}

void AKTremoloDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);

        // do ramping every 8 samples
        if ((frameOffset & 0x7) == 0) {
            data->frequencyRamp.advanceTo(now + frameOffset);
            data->depthRamp.advanceTo(now + frameOffset);
        }

        data->trem->freq = data->frequencyRamp.getValue() * 0.5;
        data->trem->amp = data->depthRamp.getValue();

        float temp = 0;
        for (int channel = 0; channel < channelCount; ++channel) {
            float *in  = (float *)inputBufferLists[0]->mBuffers[channel].mData  + frameOffset;
            float *out = (float *)outputBufferLists[0]->mBuffers[channel].mData + frameOffset;

            if (isStarted) {
                sp_osc_compute(sp, data->trem, NULL, &temp);
                *out = *in * (1.0 - temp);
            } else {
                *out = *in;
            }
        }
    }
}
