// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "AKOscillatorDSP.hpp"
#include "ParameterRamper.hpp"
#include <vector>

#import "AKSoundpipeDSPBase.hpp"

class AKOscillatorDSP : public AKSoundpipeDSPBase {
private:
    sp_osc *osc;
    sp_ftbl *ftbl;
    std::vector<float> waveform;
    ParameterRamper frequencyRamp;
    ParameterRamper amplitudeRamp;
    ParameterRamper detuningOffsetRamp;
    ParameterRamper detuningMultiplierRamp;

public:
    AKOscillatorDSP() {
        parameters[AKOscillatorParameterFrequency] = &frequencyRamp;
        parameters[AKOscillatorParameterAmplitude] = &amplitudeRamp;
        parameters[AKOscillatorParameterDetuningOffset] = &detuningOffsetRamp;
        parameters[AKOscillatorParameterDetuningMultiplier] = &detuningMultiplierRamp;
    }

    void setWavetable(const float* table, size_t length, int index) {
        waveform = std::vector<float>(table, table + length);
        reset();
    }

    void init(int channelCount, double sampleRate) {
        AKSoundpipeDSPBase::init(channelCount, sampleRate);
        sp_ftbl_create(sp, &ftbl, waveform.size());
        std::copy(waveform.cbegin(), waveform.cend(), ftbl->tbl);
        sp_osc_create(&osc);
        sp_osc_init(sp, osc, ftbl, 0);
    }

    void deinit() {
        AKSoundpipeDSPBase::deinit();
        sp_osc_destroy(&osc);
        sp_ftbl_destroy(&ftbl);
    }

    void reset() {
        AKSoundpipeDSPBase::reset();
        if (!isInitialized) return;
        sp_osc_init(sp, osc, ftbl, 0);
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {
        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            int frameOffset = int(frameIndex + bufferOffset);

            float frequency = frequencyRamp.getAndStep();
            float detuneMultiplier = detuningMultiplierRamp.getAndStep();
            float detuneOffset = detuningOffsetRamp.getAndStep();
            osc->freq = frequency * detuneMultiplier + detuneOffset;
            osc->amp = amplitudeRamp.getAndStep();

            float temp = 0;
            for (int channel = 0; channel < channelCount; ++channel) {
                float *out = (float *)outputBufferLists[0]->mBuffers[channel].mData + frameOffset;

                if (isStarted) {
                    if (channel == 0) {
                        sp_osc_compute(sp, osc, nil, &temp);
                    }
                    *out = temp;
                } else {
                    *out = 0.0;
                }
            }
        }
    }
};

extern "C" AKDSPRef createOscillatorDSP() {
    return new AKOscillatorDSP();
}
