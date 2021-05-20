// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "SoundpipeDSPBase.h"
#include "ParameterRamper.h"
#include "Soundpipe.h"
#include <vector>

enum FMOscillatorParameter : AUParameterAddress {
    FMOscillatorParameterBaseFrequency,
    FMOscillatorParameterCarrierMultiplier,
    FMOscillatorParameterModulatingMultiplier,
    FMOscillatorParameterModulationIndex,
    FMOscillatorParameterAmplitude,
};

class FMOscillatorDSP : public SoundpipeDSPBase {
private:
    sp_fosc *fosc;
    sp_ftbl *ftbl;
    std::vector<float> waveform;
    ParameterRamper baseFrequencyRamp;
    ParameterRamper carrierMultiplierRamp;
    ParameterRamper modulatingMultiplierRamp;
    ParameterRamper modulationIndexRamp;
    ParameterRamper amplitudeRamp;

public:
    FMOscillatorDSP() : SoundpipeDSPBase(/*inputBusCount*/0) {
        parameters[FMOscillatorParameterBaseFrequency] = &baseFrequencyRamp;
        parameters[FMOscillatorParameterCarrierMultiplier] = &carrierMultiplierRamp;
        parameters[FMOscillatorParameterModulatingMultiplier] = &modulatingMultiplierRamp;
        parameters[FMOscillatorParameterModulationIndex] = &modulationIndexRamp;
        parameters[FMOscillatorParameterAmplitude] = &amplitudeRamp;
    }

    void setWavetable(const float* table, size_t length, int index) override {
        waveform = std::vector<float>(table, table + length);
        reset();
    }

    void init(int channelCount, double sampleRate) override {
        SoundpipeDSPBase::init(channelCount, sampleRate);
        sp_ftbl_create(sp, &ftbl, waveform.size());
        std::copy(waveform.cbegin(), waveform.cend(), ftbl->tbl);
        sp_fosc_create(&fosc);
        sp_fosc_init(sp, fosc, ftbl);
    }

    void deinit() override {
        SoundpipeDSPBase::deinit();
        sp_fosc_destroy(&fosc);
        sp_ftbl_destroy(&ftbl);
    }

    void reset() override {
        SoundpipeDSPBase::reset();
        if (!isInitialized) return;
        sp_fosc_init(sp, fosc, ftbl);
    }

    void process(FrameRange range) override {

        for (int i : range) {

                fosc->freq = baseFrequencyRamp.getAndStep();
                fosc->car = carrierMultiplierRamp.getAndStep();
                fosc->mod = modulatingMultiplierRamp.getAndStep();
                fosc->indx = modulationIndexRamp.getAndStep();
                fosc->amp = amplitudeRamp.getAndStep();
            
            sp_fosc_compute(sp, fosc, nil, &outputSample(0, i));
        }
        cloneFirstChannel(range);
    }
};

AK_REGISTER_DSP(FMOscillatorDSP, "fosc")
AK_REGISTER_PARAMETER(FMOscillatorParameterBaseFrequency)
AK_REGISTER_PARAMETER(FMOscillatorParameterCarrierMultiplier)
AK_REGISTER_PARAMETER(FMOscillatorParameterModulatingMultiplier)
AK_REGISTER_PARAMETER(FMOscillatorParameterModulationIndex)
AK_REGISTER_PARAMETER(FMOscillatorParameterAmplitude)
