// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "AKPhaseDistortionOscillatorDSP.hpp"
#include "AKLinearParameterRamp.hpp"
#include <vector>

extern "C" AKDSPRef createPhaseDistortionOscillatorDSP() {
    return new AKPhaseDistortionOscillatorDSP();
}

struct AKPhaseDistortionOscillatorDSP::InternalData {
    sp_pdhalf *pdhalf;
    sp_tabread *tabread;
    sp_phasor *phasor;
    sp_ftbl *ftbl;
    std::vector<float> waveform;
    AKLinearParameterRamp frequencyRamp;
    AKLinearParameterRamp amplitudeRamp;
    AKLinearParameterRamp phaseDistortionRamp;
    AKLinearParameterRamp detuningOffsetRamp;
    AKLinearParameterRamp detuningMultiplierRamp;
};

AKPhaseDistortionOscillatorDSP::AKPhaseDistortionOscillatorDSP() : data(new InternalData) {
    parameters[AKPhaseDistortionOscillatorParameterFrequency] = &data->frequencyRamp;
    parameters[AKPhaseDistortionOscillatorParameterAmplitude] = &data->amplitudeRamp;
    parameters[AKPhaseDistortionOscillatorParameterPhaseDistortion] = &data->phaseDistortionRamp;
    parameters[AKPhaseDistortionOscillatorParameterDetuningOffset] = &data->detuningOffsetRamp;
    parameters[AKPhaseDistortionOscillatorParameterDetuningMultiplier] = &data->detuningMultiplierRamp;
    
    isStarted = false;
}

void AKPhaseDistortionOscillatorDSP::setWavetable(const float* table, size_t length, int index) {
    data->waveform = std::vector<float>(table, table + length);
    reset();
}

void AKPhaseDistortionOscillatorDSP::init(int channelCount, double sampleRate) {
    AKSoundpipeDSPBase::init(channelCount, sampleRate);
    sp_ftbl_create(sp, &data->ftbl, data->waveform.size());
    std::copy(data->waveform.cbegin(), data->waveform.cend(), data->ftbl->tbl);
    sp_pdhalf_create(&data->pdhalf);
    sp_pdhalf_init(sp, data->pdhalf);
    sp_tabread_create(&data->tabread);
    sp_tabread_init(sp, data->tabread, data->ftbl, 1);
    sp_phasor_create(&data->phasor);
    sp_phasor_init(sp, data->phasor, 0);
}

void AKPhaseDistortionOscillatorDSP::deinit() {
    AKSoundpipeDSPBase::deinit();
    sp_phasor_destroy(&data->phasor);
    sp_pdhalf_destroy(&data->pdhalf);
    sp_tabread_destroy(&data->tabread);
    sp_ftbl_destroy(&data->ftbl);
}

void AKPhaseDistortionOscillatorDSP::reset() {
    AKSoundpipeDSPBase::reset();
    if (!isInitialized) return;
    sp_pdhalf_init(sp, data->pdhalf);
    sp_tabread_init(sp, data->tabread, data->ftbl, 1);
    sp_phasor_init(sp, data->phasor, 0);
}

void AKPhaseDistortionOscillatorDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {
    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);

        // do ramping every 8 samples
        if ((frameOffset & 0x7) == 0) {
            data->frequencyRamp.advanceTo(now + frameOffset);
            data->amplitudeRamp.advanceTo(now + frameOffset);
            data->phaseDistortionRamp.advanceTo(now + frameOffset);
            data->detuningOffsetRamp.advanceTo(now + frameOffset);
            data->detuningMultiplierRamp.advanceTo(now + frameOffset);
        }
        float frequency = data->frequencyRamp.getValue();
        float amplitude = data->amplitudeRamp.getValue();
        float phaseDistortion = data->phaseDistortionRamp.getValue();
        float detuningOffset = data->detuningOffsetRamp.getValue();
        float detuningMultiplier = data->detuningMultiplierRamp.getValue();
        data->phasor->freq = frequency * detuningMultiplier + detuningOffset;
        data->pdhalf->amount = phaseDistortion;

        float temp = 0;
        float pd = 0;
        float ph = 0;

        for (int channel = 0; channel < channelCount; ++channel) {
            float *out = (float *)outputBufferLists[0]->mBuffers[channel].mData + frameOffset;

            if (isStarted) {
                if (channel == 0) {
                    sp_phasor_compute(sp, data->phasor, NULL, &ph);
                    sp_pdhalf_compute(sp, data->pdhalf, &ph, &pd);
                    data->tabread->index = pd;
                    sp_tabread_compute(sp, data->tabread, NULL, &temp);

                }
                *out = temp * amplitude;
            } else {
                *out = 0.0;
            }
        }
    }
}
