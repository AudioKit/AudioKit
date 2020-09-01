// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "AKSoundpipeDSPBase.hpp"
#include "ParameterRamper.hpp"
#include "soundpipe.h"

enum AKPWMOscillatorParameter : AUParameterAddress {
    AKPWMOscillatorParameterFrequency,
    AKPWMOscillatorParameterAmplitude,
    AKPWMOscillatorParameterPulseWidth,
    AKPWMOscillatorParameterDetuningOffset,
    AKPWMOscillatorParameterDetuningMultiplier,
};

class AKPWMOscillatorDSP : public AKSoundpipeDSPBase {
private:
    sp_blsquare *blsquare;
    ParameterRamper frequencyRamp;
    ParameterRamper amplitudeRamp;
    ParameterRamper pulseWidthRamp;
    ParameterRamper detuningOffsetRamp;
    ParameterRamper detuningMultiplierRamp;

public:
    AKPWMOscillatorDSP() : AKSoundpipeDSPBase(/*inputBusCount*/0) {
        parameters[AKPWMOscillatorParameterFrequency] = &frequencyRamp;
        parameters[AKPWMOscillatorParameterAmplitude] = &amplitudeRamp;
        parameters[AKPWMOscillatorParameterPulseWidth] = &pulseWidthRamp;
        parameters[AKPWMOscillatorParameterDetuningOffset] = &detuningOffsetRamp;
        parameters[AKPWMOscillatorParameterDetuningMultiplier] = &detuningMultiplierRamp;

        isStarted = false;
    }

    void init(int channelCount, double sampleRate) override {
        AKSoundpipeDSPBase::init(channelCount, sampleRate);
        isStarted = false;
        sp_blsquare_create(&blsquare);
        sp_blsquare_init(sp, blsquare);
    }

    void deinit() override {
        AKSoundpipeDSPBase::deinit();
        sp_blsquare_destroy(&blsquare);
    }

    void reset() override {
        AKSoundpipeDSPBase::reset();
        if (!isInitialized) return;
        isStarted = false;
        sp_blsquare_init(sp, blsquare);
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {
        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            int frameOffset = int(frameIndex + bufferOffset);

            float frequency = frequencyRamp.getAndStep();
            float amplitude = amplitudeRamp.getAndStep();
            float pulseWidth = pulseWidthRamp.getAndStep();
            float detuningOffset = detuningOffsetRamp.getAndStep();
            float detuningMultiplier = detuningMultiplierRamp.getAndStep();

            *blsquare->freq = frequency * detuningMultiplier + detuningOffset;
            *blsquare->amp = amplitude;
            *blsquare->width = pulseWidth;

            float temp = 0;
            for (int channel = 0; channel < channelCount; ++channel) {
                float *out = (float *)outputBufferList->mBuffers[channel].mData + frameOffset;

                if (isStarted) {
                    if (channel == 0) {
                        sp_blsquare_compute(sp, blsquare, nil, &temp);
                    }
                    *out = temp;
                } else {
                    *out = 0.0;
                }
            }
        }
    }
};

AK_REGISTER_DSP(AKPWMOscillatorDSP)
AK_REGISTER_PARAMETER(AKPWMOscillatorParameterFrequency)
AK_REGISTER_PARAMETER(AKPWMOscillatorParameterAmplitude)
AK_REGISTER_PARAMETER(AKPWMOscillatorParameterPulseWidth)
AK_REGISTER_PARAMETER(AKPWMOscillatorParameterDetuningOffset)
AK_REGISTER_PARAMETER(AKPWMOscillatorParameterDetuningMultiplier)
