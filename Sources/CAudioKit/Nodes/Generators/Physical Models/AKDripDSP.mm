// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "AKSoundpipeDSPBase.hpp"
#include "ParameterRamper.hpp"
#include "soundpipe.h"

enum AKDripParameter : AUParameterAddress {
    AKDripParameterIntensity,
    AKDripParameterDampingFactor,
    AKDripParameterEnergyReturn,
    AKDripParameterMainResonantFrequency,
    AKDripParameterFirstResonantFrequency,
    AKDripParameterSecondResonantFrequency,
    AKDripParameterAmplitude,
};

class AKDripDSP : public AKSoundpipeDSPBase {
private:
    sp_drip *drip;
    ParameterRamper intensityRamp;
    ParameterRamper dampingFactorRamp;
    ParameterRamper energyReturnRamp;
    ParameterRamper mainResonantFrequencyRamp;
    ParameterRamper firstResonantFrequencyRamp;
    ParameterRamper secondResonantFrequencyRamp;
    ParameterRamper amplitudeRamp;

public:
    AKDripDSP() {
        parameters[AKDripParameterIntensity] = &intensityRamp;
        parameters[AKDripParameterDampingFactor] = &dampingFactorRamp;
        parameters[AKDripParameterEnergyReturn] = &energyReturnRamp;
        parameters[AKDripParameterMainResonantFrequency] = &mainResonantFrequencyRamp;
        parameters[AKDripParameterFirstResonantFrequency] = &firstResonantFrequencyRamp;
        parameters[AKDripParameterSecondResonantFrequency] = &secondResonantFrequencyRamp;
        parameters[AKDripParameterAmplitude] = &amplitudeRamp;
    }

    void init(int channelCount, double sampleRate) override {
        AKSoundpipeDSPBase::init(channelCount, sampleRate);
        sp_drip_create(&drip);
        sp_drip_init(sp, drip, 0.9);
    }

    void deinit() override {
        AKSoundpipeDSPBase::deinit();
        sp_drip_destroy(&drip);
    }

    void reset() override {
        AKSoundpipeDSPBase::reset();
        if (!isInitialized) return;
        sp_drip_init(sp, drip, 0.9);
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {
        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            int frameOffset = int(frameIndex + bufferOffset);

            drip->num_tubes = intensityRamp.getAndStep();
            drip->damp = dampingFactorRamp.getAndStep();
            drip->shake_max = energyReturnRamp.getAndStep();
            drip->freq = mainResonantFrequencyRamp.getAndStep();
            drip->freq1 = firstResonantFrequencyRamp.getAndStep();
            drip->freq2 = secondResonantFrequencyRamp.getAndStep();
            drip->amp = amplitudeRamp.getAndStep();
            float temp = 0;
            for (int channel = 0; channel < channelCount; ++channel) {
                float *out = (float *)outputBufferList->mBuffers[channel].mData + frameOffset;

                if (isStarted) {
                    if (channel == 0) {
                        sp_drip_compute(sp, drip, nil, &temp);
                    }
                    *out = temp;
                } else {
                    *out = 0.0;
                }
            }
        }
    }
};

AK_REGISTER_DSP(AKDripDSP)
AK_REGISTER_PARAMETER(AKDripParameterIntensity)
AK_REGISTER_PARAMETER(AKDripParameterDampingFactor)
AK_REGISTER_PARAMETER(AKDripParameterEnergyReturn)
AK_REGISTER_PARAMETER(AKDripParameterMainResonantFrequency)
AK_REGISTER_PARAMETER(AKDripParameterFirstResonantFrequency)
AK_REGISTER_PARAMETER(AKDripParameterSecondResonantFrequency)
AK_REGISTER_PARAMETER(AKDripParameterAmplitude)
