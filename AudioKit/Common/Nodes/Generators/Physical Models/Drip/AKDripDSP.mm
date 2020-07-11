// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "AKDripDSP.hpp"
#include "ParameterRamper.hpp"

#import "AKSoundpipeDSPBase.hpp"

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

    void init(int channelCount, double sampleRate) {
        AKSoundpipeDSPBase::init(channelCount, sampleRate);
        sp_drip_create(&drip);
        sp_drip_init(sp, drip, 0.9);
    }

    void deinit() {
        AKSoundpipeDSPBase::deinit();
        sp_drip_destroy(&drip);
    }

    void reset() {
        AKSoundpipeDSPBase::reset();
        if (!isInitialized) return;
        sp_drip_init(sp, drip, 0.9);
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {
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
                float *out = (float *)outputBufferLists[0]->mBuffers[channel].mData + frameOffset;

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

extern "C" AKDSPRef createDripDSP() {
    return new AKDripDSP();
}
