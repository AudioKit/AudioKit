// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "AKSoundpipeDSPBase.hpp"
#include "ParameterRamper.hpp"
#include "soundpipe.h"
#include "vocwrapper.h"

enum AKVocalTractParameter : AUParameterAddress {
    AKVocalTractParameterFrequency,
    AKVocalTractParameterTonguePosition,
    AKVocalTractParameterTongueDiameter,
    AKVocalTractParameterTenseness,
    AKVocalTractParameterNasality,
};

class AKVocalTractDSP : public AKSoundpipeDSPBase {
private:
    sp_vocwrapper *vocwrapper;
    ParameterRamper frequencyRamp;
    ParameterRamper tonguePositionRamp;
    ParameterRamper tongueDiameterRamp;
    ParameterRamper tensenessRamp;
    ParameterRamper nasalityRamp;

public:
    AKVocalTractDSP() : AKSoundpipeDSPBase(/*inputBusCount*/0) {
        parameters[AKVocalTractParameterFrequency] = &frequencyRamp;
        parameters[AKVocalTractParameterTonguePosition] = &tonguePositionRamp;
        parameters[AKVocalTractParameterTongueDiameter] = &tongueDiameterRamp;
        parameters[AKVocalTractParameterTenseness] = &tensenessRamp;
        parameters[AKVocalTractParameterNasality] = &nasalityRamp;
    }

    void init(int channelCount, double sampleRate) override {
        AKSoundpipeDSPBase::init(channelCount, sampleRate);

        sp_vocwrapper_create(&vocwrapper);
        sp_vocwrapper_init(sp, vocwrapper);
        vocwrapper->freq = 160.0;
        vocwrapper->pos = 0.5;
        vocwrapper->diam = 1.0;
        vocwrapper->tenseness = 0.6;
        vocwrapper->nasal = 0.0;

        isStarted = false;
    }

    void deinit() override {
        AKSoundpipeDSPBase::deinit();
        sp_vocwrapper_destroy(&vocwrapper);
    }


    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {
        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            int frameOffset = int(frameIndex + bufferOffset);

            float frequency = frequencyRamp.getAndStep();
            float tonguePosition = tonguePositionRamp.getAndStep();
            float tongueDiameter = tongueDiameterRamp.getAndStep();
            float tenseness = tensenessRamp.getAndStep();
            float nasality = nasalityRamp.getAndStep();
            vocwrapper->freq = frequency;
            vocwrapper->pos = tonguePosition;
            vocwrapper->diam = tongueDiameter;
            vocwrapper->tenseness = tenseness;
            vocwrapper->nasal = nasality;

            float temp = 0;
            for (int channel = 0; channel < channelCount; ++channel) {
                float *out = (float *)outputBufferList->mBuffers[channel].mData + frameOffset;

                if (isStarted) {
                    if (channel == 0) {
                        sp_vocwrapper_compute(sp, vocwrapper, nil, &temp);
                    }
                    *out = temp;
                } else {
                    *out = 0.0;
                }
            }
        }
    }
};

AK_REGISTER_DSP(AKVocalTractDSP)
AK_REGISTER_PARAMETER(AKVocalTractParameterFrequency)
AK_REGISTER_PARAMETER(AKVocalTractParameterTonguePosition)
AK_REGISTER_PARAMETER(AKVocalTractParameterTongueDiameter)
AK_REGISTER_PARAMETER(AKVocalTractParameterTenseness)
AK_REGISTER_PARAMETER(AKVocalTractParameterNasality)
