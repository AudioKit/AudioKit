// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "SoundpipeDSPBase.h"
#include "ParameterRamper.h"
#include "soundpipe.h"
#include <vector>

enum MorphingOscillatorParameter : AUParameterAddress {
    MorphingOscillatorParameterFrequency,
    MorphingOscillatorParameterAmplitude,
    MorphingOscillatorParameterIndex,
    MorphingOscillatorParameterDetuningOffset,
    MorphingOscillatorParameterDetuningMultiplier,
};

class MorphingOscillatorDSP : public SoundpipeDSPBase {
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
    MorphingOscillatorDSP() : SoundpipeDSPBase(/*inputBusCount*/0) {
        parameters[MorphingOscillatorParameterFrequency] = &frequencyRamp;
        parameters[MorphingOscillatorParameterAmplitude] = &amplitudeRamp;
        parameters[MorphingOscillatorParameterIndex] = &indexRamp;
        parameters[MorphingOscillatorParameterDetuningOffset] = &detuningOffsetRamp;
        parameters[MorphingOscillatorParameterDetuningMultiplier] = &detuningMultiplierRamp;

        isStarted = false;
    }

    void setWavetable(const float* table, size_t length, int index) override {
        waveforms[index] = std::vector<float>(table, table + length);
        reset();
    }

    void init(int channelCount, double sampleRate) override {
        SoundpipeDSPBase::init(channelCount, sampleRate);
        for (uint32_t i = 0; i < 4; i++) {
            sp_ftbl_create(sp, &ft_array[i], waveforms[i].size());
            std::copy(waveforms[i].cbegin(), waveforms[i].cend(), ft_array[i]->tbl);
        }
        sp_oscmorph_create(&oscmorph);
        sp_oscmorph_init(sp, oscmorph, ft_array, 4, 0);
    }

    void deinit() override {
        SoundpipeDSPBase::deinit();
        sp_oscmorph_destroy(&oscmorph);
        for (uint32_t i = 0; i < 4; i++) {
            sp_ftbl_destroy(&ft_array[i]);
        }
    }

    void reset() override {
        SoundpipeDSPBase::reset();
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

AK_REGISTER_DSP(MorphingOscillatorDSP, "morf")
AK_REGISTER_PARAMETER(MorphingOscillatorParameterFrequency)
AK_REGISTER_PARAMETER(MorphingOscillatorParameterAmplitude)
AK_REGISTER_PARAMETER(MorphingOscillatorParameterIndex)
AK_REGISTER_PARAMETER(MorphingOscillatorParameterDetuningOffset)
AK_REGISTER_PARAMETER(MorphingOscillatorParameterDetuningMultiplier)
