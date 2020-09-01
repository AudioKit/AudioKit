// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "AKSoundpipeDSPBase.hpp"
#include "ParameterRamper.hpp"
#include "soundpipe.h"
#include <vector>

enum AKFMOscillatorParameter : AUParameterAddress {
    AKFMOscillatorParameterBaseFrequency,
    AKFMOscillatorParameterCarrierMultiplier,
    AKFMOscillatorParameterModulatingMultiplier,
    AKFMOscillatorParameterModulationIndex,
    AKFMOscillatorParameterAmplitude,
};

class AKFMOscillatorDSP : public AKSoundpipeDSPBase {
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
    AKFMOscillatorDSP() : AKSoundpipeDSPBase(/*inputBusCount*/0) {
        parameters[AKFMOscillatorParameterBaseFrequency] = &baseFrequencyRamp;
        parameters[AKFMOscillatorParameterCarrierMultiplier] = &carrierMultiplierRamp;
        parameters[AKFMOscillatorParameterModulatingMultiplier] = &modulatingMultiplierRamp;
        parameters[AKFMOscillatorParameterModulationIndex] = &modulationIndexRamp;
        parameters[AKFMOscillatorParameterAmplitude] = &amplitudeRamp;
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
        sp_fosc_create(&fosc);
        sp_fosc_init(sp, fosc, ftbl);
    }

    void deinit() override {
        AKSoundpipeDSPBase::deinit();
        sp_fosc_destroy(&fosc);
        sp_ftbl_destroy(&ftbl);
    }

    void reset() override {
        AKSoundpipeDSPBase::reset();
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

AK_REGISTER_DSP(AKFMOscillatorDSP)
AK_REGISTER_PARAMETER(AKFMOscillatorParameterBaseFrequency)
AK_REGISTER_PARAMETER(AKFMOscillatorParameterCarrierMultiplier)
AK_REGISTER_PARAMETER(AKFMOscillatorParameterModulatingMultiplier)
AK_REGISTER_PARAMETER(AKFMOscillatorParameterModulationIndex)
AK_REGISTER_PARAMETER(AKFMOscillatorParameterAmplitude)
