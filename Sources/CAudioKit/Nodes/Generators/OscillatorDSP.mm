// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "SoundpipeDSPBase.h"
#include "ParameterRamper.h"
#include "Soundpipe.h"
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

    void process(FrameRange range) override {

        for (int i : range) {

            float frequency = frequencyRamp.getAndStep();
            float detuneMultiplier = detuningMultiplierRamp.getAndStep();
            float detuneOffset = detuningOffsetRamp.getAndStep();
            osc->freq = frequency * detuneMultiplier + detuneOffset;
            osc->amp = amplitudeRamp.getAndStep();

            sp_osc_compute(sp, osc, nil, &outputSample(0, i));
        }
        cloneFirstChannel(range);

    }
};

AK_REGISTER_DSP(OscillatorDSP, "oscl")
AK_REGISTER_PARAMETER(OscillatorParameterFrequency)
AK_REGISTER_PARAMETER(OscillatorParameterAmplitude)
AK_REGISTER_PARAMETER(OscillatorParameterDetuningOffset)
AK_REGISTER_PARAMETER(OscillatorParameterDetuningMultiplier)
