// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "SoundpipeDSPBase.h"
#include "ParameterRamper.h"
#include "soundpipe.h"
#include <vector>

enum OscillatorParameter : AUParameterAddress {
    OscillatorParameterFrequency,
    OscillatorParameterAmplitude,
    OscillatorParameterDetuningOffset,
    OscillatorParameterDetuningMultiplier,
};

class OscillatorDSP : public SoundpipeDSPBase {
private:
    sp_osc *osc = nullptr;
    sp_ftbl *ftbl = nullptr;
    std::vector<float> waveform;
    ParameterRamper frequencyRamp;
    ParameterRamper amplitudeRamp;
    ParameterRamper detuningOffsetRamp;
    ParameterRamper detuningMultiplierRamp;

public:
    OscillatorDSP() : SoundpipeDSPBase(/*inputBusCount*/0) {
        parameters[OscillatorParameterFrequency] = &frequencyRamp;
        parameters[OscillatorParameterAmplitude] = &amplitudeRamp;
        parameters[OscillatorParameterDetuningOffset] = &detuningOffsetRamp;
        parameters[OscillatorParameterDetuningMultiplier] = &detuningMultiplierRamp;
        isStarted = false;
    }

    void setWavetable(const float* table, size_t length, int index) override {
        waveform = std::vector<float>(table, table + length);
        reset();
    }

    void init(int channelCount, double sampleRate) override {
        SoundpipeDSPBase::init(channelCount, sampleRate);
        sp_ftbl_create(sp, &ftbl, waveform.size());
        std::copy(waveform.cbegin(), waveform.cend(), ftbl->tbl);
        sp_osc_create(&osc);
        sp_osc_init(sp, osc, ftbl, 0);
    }

    void deinit() override {
        SoundpipeDSPBase::deinit();
        sp_osc_destroy(&osc);
        sp_ftbl_destroy(&ftbl);
    }

    void reset() override {
        SoundpipeDSPBase::reset();
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
                        // DebugDSP(OscillatorDebugPhase, osc->lphs);
                    }
                    *out = temp;
                } else {
                    *out = 0.0;
                }
            }
        }
    }
};

AK_REGISTER_DSP(OscillatorDSP, "oscl")
AK_REGISTER_PARAMETER(OscillatorParameterFrequency)
AK_REGISTER_PARAMETER(OscillatorParameterAmplitude)
AK_REGISTER_PARAMETER(OscillatorParameterDetuningOffset)
AK_REGISTER_PARAMETER(OscillatorParameterDetuningMultiplier)
