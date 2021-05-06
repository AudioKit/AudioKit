// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "SoundpipeDSPBase.h"
#include "ParameterRamper.h"
#include "soundpipe.h"
#include "vocwrapper.h"

enum VocalTractParameter : AUParameterAddress {
    VocalTractParameterFrequency,
    VocalTractParameterTonguePosition,
    VocalTractParameterTongueDiameter,
    VocalTractParameterTenseness,
    VocalTractParameterNasality,
};

class VocalTractDSP : public SoundpipeDSPBase {
private:
    sp_vocwrapper *vocwrapper;
    ParameterRamper frequencyRamp;
    ParameterRamper tonguePositionRamp;
    ParameterRamper tongueDiameterRamp;
    ParameterRamper tensenessRamp;
    ParameterRamper nasalityRamp;

public:
    VocalTractDSP() : SoundpipeDSPBase(/*inputBusCount*/0) {
        parameters[VocalTractParameterFrequency] = &frequencyRamp;
        parameters[VocalTractParameterTonguePosition] = &tonguePositionRamp;
        parameters[VocalTractParameterTongueDiameter] = &tongueDiameterRamp;
        parameters[VocalTractParameterTenseness] = &tensenessRamp;
        parameters[VocalTractParameterNasality] = &nasalityRamp;
    }

    void init(int channelCount, double sampleRate) override {
        SoundpipeDSPBase::init(channelCount, sampleRate);

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
        SoundpipeDSPBase::deinit();
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

AK_REGISTER_DSP(VocalTractDSP, "vocw")
AK_REGISTER_PARAMETER(VocalTractParameterFrequency)
AK_REGISTER_PARAMETER(VocalTractParameterTonguePosition)
AK_REGISTER_PARAMETER(VocalTractParameterTongueDiameter)
AK_REGISTER_PARAMETER(VocalTractParameterTenseness)
AK_REGISTER_PARAMETER(VocalTractParameterNasality)
