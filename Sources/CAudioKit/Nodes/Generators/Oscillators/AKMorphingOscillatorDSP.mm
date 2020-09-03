// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "AKSoundpipeDSPBase.hpp"
#include "ParameterRamper.hpp"
#include "soundpipe.h"
#include <vector>

enum AKMorphingOscillatorParameter : AUParameterAddress {
    AKMorphingOscillatorParameterFrequency,
    AKMorphingOscillatorParameterAmplitude,
    AKMorphingOscillatorParameterIndex,
    AKMorphingOscillatorParameterDetuningOffset,
    AKMorphingOscillatorParameterDetuningMultiplier,
};

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
    AKMorphingOscillatorDSP() : AKSoundpipeDSPBase(/*inputBusCount*/0) {
        parameters[AKMorphingOscillatorParameterFrequency] = &frequencyRamp;
        parameters[AKMorphingOscillatorParameterAmplitude] = &amplitudeRamp;
        parameters[AKMorphingOscillatorParameterIndex] = &indexRamp;
        parameters[AKMorphingOscillatorParameterDetuningOffset] = &detuningOffsetRamp;
        parameters[AKMorphingOscillatorParameterDetuningMultiplier] = &detuningMultiplierRamp;

        isStarted = false;
    }

    void setWavetable(const float* table, size_t length, int index) override {
        waveforms[index] = std::vector<float>(table, table + length);
        reset();
    }

    void init(int channelCount, double sampleRate) override {
        AKSoundpipeDSPBase::init(channelCount, sampleRate);
        for (uint32_t i = 0; i < 4; i++) {
            sp_ftbl_create(sp, &ft_array[i], waveforms[i].size());
            std::copy(waveforms[i].cbegin(), waveforms[i].cend(), ft_array[i]->tbl);
        }
        sp_oscmorph_create(&oscmorph);
        sp_oscmorph_init(sp, oscmorph, ft_array, 4, 0);
    }

    void deinit() override {
        AKSoundpipeDSPBase::deinit();
        sp_oscmorph_destroy(&oscmorph);
        for (uint32_t i = 0; i < 4; i++) {
            sp_ftbl_destroy(&ft_array[i]);
        }
    }

    void reset() override {
        AKSoundpipeDSPBase::reset();
        if (!isInitialized) return;
        sp_oscmorph_init(sp, oscmorph, ft_array, 4, 0);
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {
        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            int frameOffset = int(frameIndex + bufferOffset);

            oscmorph->freq = frequencyRamp.getAndStep() * detuningMultiplierRamp.getAndStep() + detuningOffsetRamp.getAndStep();
            oscmorph->amp = amplitudeRamp.getAndStep();
            oscmorph->wtpos = indexRamp.getAndStep() / 3.f;

            float temp = 0;
            for (int channel = 0; channel < channelCount; ++channel) {
                float *out = (float *)outputBufferList->mBuffers[channel].mData + frameOffset;

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

AK_REGISTER_DSP(AKMorphingOscillatorDSP)
AK_REGISTER_PARAMETER(AKMorphingOscillatorParameterFrequency)
AK_REGISTER_PARAMETER(AKMorphingOscillatorParameterAmplitude)
AK_REGISTER_PARAMETER(AKMorphingOscillatorParameterIndex)
AK_REGISTER_PARAMETER(AKMorphingOscillatorParameterDetuningOffset)
AK_REGISTER_PARAMETER(AKMorphingOscillatorParameterDetuningMultiplier)
