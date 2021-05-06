// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "SoundpipeDSPBase.h"
#include "ParameterRamper.h"
#include "soundpipe.h"
#include <vector>

enum PhaseDistortionOscillatorParameter : AUParameterAddress {
    PhaseDistortionOscillatorParameterFrequency,
    PhaseDistortionOscillatorParameterAmplitude,
    PhaseDistortionOscillatorParameterPhaseDistortion,
    PhaseDistortionOscillatorParameterDetuningOffset,
    PhaseDistortionOscillatorParameterDetuningMultiplier,
};

class PhaseDistortionOscillatorDSP : public SoundpipeDSPBase {
private:
    sp_pdhalf *pdhalf;
    sp_tabread *tabread;
    sp_phasor *phasor;
    sp_ftbl *ftbl;
    std::vector<float> waveform;
    ParameterRamper frequencyRamp;
    ParameterRamper amplitudeRamp;
    ParameterRamper phaseDistortionRamp;
    ParameterRamper detuningOffsetRamp;
    ParameterRamper detuningMultiplierRamp;

public:
    PhaseDistortionOscillatorDSP() : SoundpipeDSPBase(/*inputBusCount*/0) {
        parameters[PhaseDistortionOscillatorParameterFrequency] = &frequencyRamp;
        parameters[PhaseDistortionOscillatorParameterAmplitude] = &amplitudeRamp;
        parameters[PhaseDistortionOscillatorParameterPhaseDistortion] = &phaseDistortionRamp;
        parameters[PhaseDistortionOscillatorParameterDetuningOffset] = &detuningOffsetRamp;
        parameters[PhaseDistortionOscillatorParameterDetuningMultiplier] = &detuningMultiplierRamp;
        
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
        sp_pdhalf_create(&pdhalf);
        sp_pdhalf_init(sp, pdhalf);
        sp_tabread_create(&tabread);
        sp_tabread_init(sp, tabread, ftbl, 1);
        sp_phasor_create(&phasor);
        sp_phasor_init(sp, phasor, 0);
    }

    void deinit() override {
        SoundpipeDSPBase::deinit();
        sp_phasor_destroy(&phasor);
        sp_pdhalf_destroy(&pdhalf);
        sp_tabread_destroy(&tabread);
        sp_ftbl_destroy(&ftbl);
    }

    void reset() override {
        SoundpipeDSPBase::reset();
        if (!isInitialized) return;
        sp_pdhalf_init(sp, pdhalf);
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {
        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            int frameOffset = int(frameIndex + bufferOffset);
            
            float frequency = frequencyRamp.getAndStep();
            float amplitude = amplitudeRamp.getAndStep();
            float phaseDistortion = phaseDistortionRamp.getAndStep();
            float detuningOffset = detuningOffsetRamp.getAndStep();
            float detuningMultiplier = detuningMultiplierRamp.getAndStep();
            phasor->freq = frequency * detuningMultiplier + detuningOffset;
            pdhalf->amount = phaseDistortion;
            
            float temp = 0;
            float pd = 0;
            float ph = 0;
            
            for (int channel = 0; channel < channelCount; ++channel) {
                float *out = (float *)outputBufferList->mBuffers[channel].mData + frameOffset;

                if (isStarted) {
                    if (channel == 0) {
                        sp_phasor_compute(sp, phasor, NULL, &ph);
//                        DebugDSP(PhaseDistortionOscillatorDebugPhase, ph);
                        sp_pdhalf_compute(sp, pdhalf, &ph, &pd);
                        tabread->index = pd;
                        sp_tabread_compute(sp, tabread, NULL, &temp);
                        
                    }
                    *out = temp * amplitude;
                } else {
                    *out = 0.0;
                }
            }
        }
    }
};

AK_REGISTER_DSP(PhaseDistortionOscillatorDSP, "pdho")
AK_REGISTER_PARAMETER(PhaseDistortionOscillatorParameterFrequency)
AK_REGISTER_PARAMETER(PhaseDistortionOscillatorParameterAmplitude)
AK_REGISTER_PARAMETER(PhaseDistortionOscillatorParameterPhaseDistortion)
AK_REGISTER_PARAMETER(PhaseDistortionOscillatorParameterDetuningOffset)
AK_REGISTER_PARAMETER(PhaseDistortionOscillatorParameterDetuningMultiplier)
