// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "AKFMOscillatorDSP.hpp"
#include "ParameterRamper.hpp"
#include <vector>

#import "AKSoundpipeDSPBase.hpp"

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
    AKFMOscillatorDSP() {
        parameters[AKFMOscillatorParameterBaseFrequency] = &baseFrequencyRamp;
        parameters[AKFMOscillatorParameterCarrierMultiplier] = &carrierMultiplierRamp;
        parameters[AKFMOscillatorParameterModulatingMultiplier] = &modulatingMultiplierRamp;
        parameters[AKFMOscillatorParameterModulationIndex] = &modulationIndexRamp;
        parameters[AKFMOscillatorParameterAmplitude] = &amplitudeRamp;
    }

    void setWavetable(const float* table, size_t length, int index) {
        waveform = std::vector<float>(table, table + length);
        reset();
    }

    void init(int channelCount, double sampleRate) {
        AKSoundpipeDSPBase::init(channelCount, sampleRate);
        sp_ftbl_create(sp, &ftbl, waveform.size());
        std::copy(waveform.cbegin(), waveform.cend(), ftbl->tbl);
        sp_fosc_create(&fosc);
        sp_fosc_init(sp, fosc, ftbl);
    }

    void deinit() {
        AKSoundpipeDSPBase::deinit();
        sp_fosc_destroy(&fosc);
        sp_ftbl_destroy(&ftbl);
    }

    void reset() {
        AKSoundpipeDSPBase::reset();
        if (!isInitialized) return;
        sp_fosc_init(sp, fosc, ftbl);
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {
        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            int frameOffset = int(frameIndex + bufferOffset);

            fosc->freq = baseFrequencyRamp.getAndStep();
            fosc->car = carrierMultiplierRamp.getAndStep();
            fosc->mod = modulatingMultiplierRamp.getAndStep();
            fosc->indx = modulationIndexRamp.getAndStep();
            fosc->amp = amplitudeRamp.getAndStep();
            float temp = 0;
            for (int channel = 0; channel < channelCount; ++channel) {
                float *out = (float *)outputBufferLists[0]->mBuffers[channel].mData + frameOffset;

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

extern "C" AKDSPRef createFMOscillatorDSP() {
    return new AKFMOscillatorDSP();
}
