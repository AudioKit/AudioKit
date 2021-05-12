// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "SoundpipeDSPBase.h"
#include "ParameterRamper.h"
#include "soundpipe.h"

enum DripParameter : AUParameterAddress {
    DripParameterIntensity,
    DripParameterDampingFactor,
    DripParameterEnergyReturn,
    DripParameterMainResonantFrequency,
    DripParameterFirstResonantFrequency,
    DripParameterSecondResonantFrequency,
    DripParameterAmplitude,
};

class DripDSP : public SoundpipeDSPBase {
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
    DripDSP() {
        parameters[DripParameterIntensity] = &intensityRamp;
        parameters[DripParameterDampingFactor] = &dampingFactorRamp;
        parameters[DripParameterEnergyReturn] = &energyReturnRamp;
        parameters[DripParameterMainResonantFrequency] = &mainResonantFrequencyRamp;
        parameters[DripParameterFirstResonantFrequency] = &firstResonantFrequencyRamp;
        parameters[DripParameterSecondResonantFrequency] = &secondResonantFrequencyRamp;
        parameters[DripParameterAmplitude] = &amplitudeRamp;
    }

    void init(int channelCount, double sampleRate) override {
        SoundpipeDSPBase::init(channelCount, sampleRate);
        sp_drip_create(&drip);
        sp_drip_init(sp, drip, 0.9);
    }

    void deinit() override {
        SoundpipeDSPBase::deinit();
        sp_drip_destroy(&drip);
    }

    void reset() override {
        SoundpipeDSPBase::reset();
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
                        sp_drip_compute(sp, drip, &internalTrigger, &temp);
                    }
                    *out = temp;
                } else {
                    *out = 0.0;
                }
            }
        }
        if (internalTrigger == 1) {
            internalTrigger = 0;
        }
    }
};

AK_REGISTER_DSP(DripDSP, "drip")
AK_REGISTER_PARAMETER(DripParameterIntensity)
AK_REGISTER_PARAMETER(DripParameterDampingFactor)
AK_REGISTER_PARAMETER(DripParameterEnergyReturn)
AK_REGISTER_PARAMETER(DripParameterMainResonantFrequency)
AK_REGISTER_PARAMETER(DripParameterFirstResonantFrequency)
AK_REGISTER_PARAMETER(DripParameterSecondResonantFrequency)
AK_REGISTER_PARAMETER(DripParameterAmplitude)
