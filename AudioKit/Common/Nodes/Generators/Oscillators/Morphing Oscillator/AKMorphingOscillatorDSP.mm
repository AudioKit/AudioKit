// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "AKMorphingOscillatorDSP.hpp"
#include "ParameterRamper.hpp"
#include <vector>

#import "AKSoundpipeDSPBase.hpp"

class AKMorphingOscillatorDSP : public AKSoundpipeDSPBase {
private:
    sp_oscmorph *oscmorph;
    sp_ftbl *ft_array[4];
    std::vector<float> waveforms[4];
    ParameterRamper frequencyRamp;
    ParameterRamper amplitudeRamp;
    ParameterRamper indexRamp;
    ParameterRamper detuningOffsetRamp;
    ParameterRamper detuningMultiplierRamp;

public:
    AKMorphingOscillatorDSP() {
        parameters[AKMorphingOscillatorParameterFrequency] = &frequencyRamp;
        parameters[AKMorphingOscillatorParameterAmplitude] = &amplitudeRamp;
        parameters[AKMorphingOscillatorParameterIndex] = &indexRamp;
        parameters[AKMorphingOscillatorParameterDetuningOffset] = &detuningOffsetRamp;
        parameters[AKMorphingOscillatorParameterDetuningMultiplier] = &detuningMultiplierRamp;

        isStarted = false;
    }

    void setWavetable(const float* table, size_t length, int index) {
        waveforms[index] = std::vector<float>(table, table + length);
        reset();
    }

    void init(int channelCount, double sampleRate) {
        AKSoundpipeDSPBase::init(channelCount, sampleRate);
        for (uint32_t i = 0; i < 4; i++) {
            sp_ftbl_create(sp, &ft_array[i], waveforms[i].size());
            std::copy(waveforms[i].cbegin(), waveforms[i].cend(), ft_array[i]->tbl);
        }
        sp_oscmorph_create(&oscmorph);
        sp_oscmorph_init(sp, oscmorph, ft_array, 4, 0);
    }

    void deinit() {
        AKSoundpipeDSPBase::deinit();
        sp_oscmorph_destroy(&oscmorph);
        for (uint32_t i = 0; i < 4; i++) {
            sp_ftbl_destroy(&ft_array[i]);
        }
    }

    void reset() {
        AKSoundpipeDSPBase::reset();
        if (!isInitialized) return;
        sp_oscmorph_init(sp, oscmorph, ft_array, 4, 0);
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {
        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            int frameOffset = int(frameIndex + bufferOffset);

            oscmorph->freq = frequencyRamp.getAndStep() * detuningMultiplierRamp.getAndStep() + detuningOffsetRamp.getAndStep();
            oscmorph->amp = amplitudeRamp.getAndStep();
            oscmorph->wtpos = indexRamp.getAndStep() / 3.f;

            float temp = 0;
            for (int channel = 0; channel < channelCount; ++channel) {
                float *out = (float *)outputBufferLists[0]->mBuffers[channel].mData + frameOffset;

                if (isStarted) {
                    if (channel == 0) {
                        sp_oscmorph_compute(sp, oscmorph, nil, &temp);
                    }
                    *out = temp;
                } else {
                    *out = 0.0;
                }
            }
        }
    }
};

extern "C" AKDSPRef createMorphingOscillatorDSP() {
    return new AKMorphingOscillatorDSP();
}
