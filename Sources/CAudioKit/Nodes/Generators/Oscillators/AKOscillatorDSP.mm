// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "AKSoundpipeDSPBase.hpp"
#include "ParameterRamper.hpp"
#include "soundpipe.h"
#include <vector>

enum AKOscillatorParameter : AUParameterAddress {
    AKOscillatorParameterFrequency,
    AKOscillatorParameterAmplitude,
    AKOscillatorParameterDetuningOffset,
    AKOscillatorParameterDetuningMultiplier,
};

class AKOscillatorDSP : public AKSoundpipeDSPBase {
private:
    sp_osc *osc = nullptr;
    sp_ftbl *ftbl = nullptr;
    std::vector<float> waveform;
    ParameterRamper frequencyRamp;
    ParameterRamper amplitudeRamp;
    ParameterRamper detuningOffsetRamp;
    ParameterRamper detuningMultiplierRamp;

public:
    AKOscillatorDSP() : AKSoundpipeDSPBase(/*inputBusCount*/0) {
        parameters[AKOscillatorParameterFrequency] = &frequencyRamp;
        parameters[AKOscillatorParameterAmplitude] = &amplitudeRamp;
        parameters[AKOscillatorParameterDetuningOffset] = &detuningOffsetRamp;
        parameters[AKOscillatorParameterDetuningMultiplier] = &detuningMultiplierRamp;
        isStarted = false;
    }

    void setWavetable(const float* table, size_t length, int index) override {
        waveform = std::vector<float>(table, table + length);
        reset();
    }

    void init(int channelCount, double sampleRate) override {
        AKSoundpipeDSPBase::init(channelCount, sampleRate);
        sp_ftbl_create(sp, &ftbl, waveform.size());
        std::copy(waveform.cbegin(), waveform.cend(), ftbl->tbl);
        sp_osc_create(&osc);
        sp_osc_init(sp, osc, ftbl, 0);
    }

    void deinit() override {
        AKSoundpipeDSPBase::deinit();
        sp_osc_destroy(&osc);
        sp_ftbl_destroy(&ftbl);
    }

    void reset() override {
        AKSoundpipeDSPBase::reset();
        if (!isInitialized) return;
        sp_osc_init(sp, osc, ftbl, 0);
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {
        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            int frameOffset = int(frameIndex + bufferOffset);

            float frequency = frequencyRamp.getAndStep();
            float detuneMultiplier = detuningMultiplierRamp.getAndStep();
            float detuneOffset = detuningOffsetRamp.getAndStep();
            osc->freq = frequency * detuneMultiplier + detuneOffset;
            osc->amp = amplitudeRamp.getAndStep();

            float temp = 0;
            for (int channel = 0; channel < channelCount; ++channel) {
                float *out = (float *)outputBufferList->mBuffers[channel].mData + frameOffset;

                if (isStarted) {
                    if (channel == 0) {
                        sp_osc_compute(sp, osc, nil, &temp);
                        // AKDebugDSP(AKOscillatorDebugPhase, osc->lphs);
                    }
                    *out = temp;
                } else {
                    *out = 0.0;
                }
            }
        }
    }
};

AK_REGISTER_DSP(AKOscillatorDSP)
AK_REGISTER_PARAMETER(AKOscillatorParameterFrequency)
AK_REGISTER_PARAMETER(AKOscillatorParameterAmplitude)
AK_REGISTER_PARAMETER(AKOscillatorParameterDetuningOffset)
AK_REGISTER_PARAMETER(AKOscillatorParameterDetuningMultiplier)
