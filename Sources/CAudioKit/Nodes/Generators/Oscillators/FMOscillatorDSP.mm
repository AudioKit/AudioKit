// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "SoundpipeDSPBase.h"
#include "ParameterRamper.h"
#include "soundpipe.h"
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

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {
        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            int frameOffset = int(frameIndex + bufferOffset);

            fosc->freq = baseFrequencyRamp.getAndStep();
            fosc->car = carrierMultiplierRamp.getAndStep();
            fosc->mod = modulatingMultiplierRamp.getAndStep();
            fosc->indx = modulationIndexRamp.getAndStep();
            fosc->amp = amplitudeRamp.getAndStep();
            float temp = 0;
            for (int channel = 0; channel < channelCount; ++channel) {
                float *out = (float *)outputBufferList->mBuffers[channel].mData + frameOffset;

                if (isStarted) {
                    if (channel == 0) {
                        sp_fosc_compute(sp, fosc, nil, &temp);
                    }
                    *out = temp;
                } else {
                    *out = 0.0;
                }
            }
        }
    }
};

AK_REGISTER_DSP(FMOscillatorDSP, "fosc")
AK_REGISTER_PARAMETER(FMOscillatorParameterBaseFrequency)
AK_REGISTER_PARAMETER(FMOscillatorParameterCarrierMultiplier)
AK_REGISTER_PARAMETER(FMOscillatorParameterModulatingMultiplier)
AK_REGISTER_PARAMETER(FMOscillatorParameterModulationIndex)
AK_REGISTER_PARAMETER(FMOscillatorParameterAmplitude)
