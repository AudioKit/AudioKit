// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "AKMorphingOscillatorDSP.hpp"
#include "AKLinearParameterRamp.hpp"
#include <vector>

extern "C" AKDSPRef createMorphingOscillatorDSP() {
    return new AKMorphingOscillatorDSP();
}

struct AKMorphingOscillatorDSP::InternalData {
    sp_oscmorph *oscmorph;
    sp_ftbl *ft_array[4];
    std::vector<float> waveforms[4];
    AKLinearParameterRamp frequencyRamp;
    AKLinearParameterRamp amplitudeRamp;
    AKLinearParameterRamp indexRamp;
    AKLinearParameterRamp detuningOffsetRamp;
    AKLinearParameterRamp detuningMultiplierRamp;
};

AKMorphingOscillatorDSP::AKMorphingOscillatorDSP() : data(new InternalData) {
    parameters[AKMorphingOscillatorParameterFrequency] = &data->frequencyRamp;
    parameters[AKMorphingOscillatorParameterAmplitude] = &data->amplitudeRamp;
    parameters[AKMorphingOscillatorParameterIndex] = &data->indexRamp;
    parameters[AKMorphingOscillatorParameterDetuningOffset] = &data->detuningOffsetRamp;
    parameters[AKMorphingOscillatorParameterDetuningMultiplier] = &data->detuningMultiplierRamp;
    
    isStarted = false;
}

void AKMorphingOscillatorDSP::setWavetable(const float* table, size_t length, int index) {
    data->waveforms[index] = std::vector<float>(table, table + length);
    reset();
}

void AKMorphingOscillatorDSP::init(int channelCount, double sampleRate) {
    AKSoundpipeDSPBase::init(channelCount, sampleRate);
    for (uint32_t i = 0; i < 4; i++) {
        sp_ftbl_create(sp, &data->ft_array[i], data->waveforms[i].size());
        std::copy(data->waveforms[i].cbegin(), data->waveforms[i].cend(), data->ft_array[i]->tbl);
    }
    sp_oscmorph_create(&data->oscmorph);
    sp_oscmorph_init(sp, data->oscmorph, data->ft_array, 4, 0);
}

void AKMorphingOscillatorDSP::deinit() {
    AKSoundpipeDSPBase::deinit();
    sp_oscmorph_destroy(&data->oscmorph);
    for (uint32_t i = 0; i < 4; i++) {
        sp_ftbl_destroy(&data->ft_array[i]);
    }
}

void AKMorphingOscillatorDSP::reset() {
    AKSoundpipeDSPBase::reset();
    if (!isInitialized) return;
    sp_oscmorph_init(sp, data->oscmorph, data->ft_array, 4, 0);
}

void AKMorphingOscillatorDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {
    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);

        // do ramping every 8 samples
        if ((frameOffset & 0x7) == 0) {
            data->frequencyRamp.advanceTo(now + frameOffset);
            data->amplitudeRamp.advanceTo(now + frameOffset);
            data->indexRamp.advanceTo(now + frameOffset);
            data->detuningOffsetRamp.advanceTo(now + frameOffset);
            data->detuningMultiplierRamp.advanceTo(now + frameOffset);
        }

        data->oscmorph->freq = data->frequencyRamp.getValue() * data->detuningMultiplierRamp.getValue() + data->detuningOffsetRamp.getValue();
        data->oscmorph->amp = data->amplitudeRamp.getValue();
        data->oscmorph->wtpos = data->indexRamp.getValue();

        float temp = 0;
        for (int channel = 0; channel < channelCount; ++channel) {
            float *out = (float *)outputBufferLists[0]->mBuffers[channel].mData + frameOffset;

            if (isStarted) {
                if (channel == 0) {
                    sp_oscmorph_compute(sp, data->oscmorph, nil, &temp);
                }
                *out = temp;
            } else {
                *out = 0.0;
            }
        }
    }
}
