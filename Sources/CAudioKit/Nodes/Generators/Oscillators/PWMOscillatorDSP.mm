// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "SoundpipeDSPBase.h"
#include "ParameterRamper.h"
#include "Soundpipe.h"

enum PWMOscillatorParameter : AUParameterAddress {
    PWMOscillatorParameterFrequency,
    PWMOscillatorParameterAmplitude,
    PWMOscillatorParameterPulseWidth,
    PWMOscillatorParameterDetuningOffset,
    PWMOscillatorParameterDetuningMultiplier,
};

class PWMOscillatorDSP : public SoundpipeDSPBase {
private:
    sp_blsquare *blsquare;
    ParameterRamper frequencyRamp;
    ParameterRamper amplitudeRamp;
    ParameterRamper pulseWidthRamp;
    ParameterRamper detuningOffsetRamp;
    ParameterRamper detuningMultiplierRamp;

public:
    PWMOscillatorDSP() : SoundpipeDSPBase(/*inputBusCount*/0) {
        parameters[PWMOscillatorParameterFrequency] = &frequencyRamp;
        parameters[PWMOscillatorParameterAmplitude] = &amplitudeRamp;
        parameters[PWMOscillatorParameterPulseWidth] = &pulseWidthRamp;
        parameters[PWMOscillatorParameterDetuningOffset] = &detuningOffsetRamp;
        parameters[PWMOscillatorParameterDetuningMultiplier] = &detuningMultiplierRamp;
    }

    void init(int channelCount, double sampleRate) override {
        SoundpipeDSPBase::init(channelCount, sampleRate);
        sp_blsquare_create(&blsquare);
        sp_blsquare_init(sp, blsquare);
    }

    void deinit() override {
        SoundpipeDSPBase::deinit();
        sp_blsquare_destroy(&blsquare);
    }

    void reset() override {
        SoundpipeDSPBase::reset();
        if (!isInitialized) return;
        sp_blsquare_init(sp, blsquare);
    }

    void process(FrameRange range) override {

        for (int i : range) {

            float frequency = frequencyRamp.getAndStep();
            float amplitude = amplitudeRamp.getAndStep();
            float pulseWidth = pulseWidthRamp.getAndStep();
            float detuningOffset = detuningOffsetRamp.getAndStep();
            float detuningMultiplier = detuningMultiplierRamp.getAndStep();

            *blsquare->freq = frequency * detuningMultiplier + detuningOffset;
            *blsquare->amp = amplitude;
            *blsquare->width = pulseWidth;
            sp_blsquare_compute(sp, blsquare, nil, &outputSample(0, i));
        }
        cloneFirstChannel(range);
    }
};

AK_REGISTER_DSP(PWMOscillatorDSP, "pwmo")
AK_REGISTER_PARAMETER(PWMOscillatorParameterFrequency)
AK_REGISTER_PARAMETER(PWMOscillatorParameterAmplitude)
AK_REGISTER_PARAMETER(PWMOscillatorParameterPulseWidth)
AK_REGISTER_PARAMETER(PWMOscillatorParameterDetuningOffset)
AK_REGISTER_PARAMETER(PWMOscillatorParameterDetuningMultiplier)
