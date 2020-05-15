// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#pragma once

#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(AUParameterAddress, AKVocalTractParameter) {
    AKVocalTractParameterFrequency,
    AKVocalTractParameterTonguePosition,
    AKVocalTractParameterTongueDiameter,
    AKVocalTractParameterTenseness,
    AKVocalTractParameterNasality,
};

#import "AKLinearParameterRamp.hpp"  // have to put this here to get it included in umbrella header

#ifndef __cplusplus

AKDSPRef createVocalTractDSP(void);

#else

#import "AKSoundpipeDSPBase.hpp"

class AKVocalTractDSP : public AKSoundpipeDSPBase {

    sp_vocwrapper *vocwrapper;

private:
    AKLinearParameterRamp frequencyRamp;
    AKLinearParameterRamp tonguePositionRamp;
    AKLinearParameterRamp tongueDiameterRamp;
    AKLinearParameterRamp tensenessRamp;
    AKLinearParameterRamp nasalityRamp;

public:
    AKVocalTractDSP() {
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

            // do ramping every 8 samples
            if ((frameOffset & 0x7) == 0) {
                frequencyRamp.advanceTo(now + frameOffset);
                tonguePositionRamp.advanceTo(now + frameOffset);
                tongueDiameterRamp.advanceTo(now + frameOffset);
                tensenessRamp.advanceTo(now + frameOffset);
                nasalityRamp.advanceTo(now + frameOffset);
            }
            float frequency = frequencyRamp.getValue();
            float tonguePosition = tonguePositionRamp.getValue();
            float tongueDiameter = tongueDiameterRamp.getValue();
            float tenseness = tensenessRamp.getValue();
            float nasality = nasalityRamp.getValue();
            vocwrapper->freq = frequency;
            vocwrapper->pos = tonguePosition;
            vocwrapper->diam = tongueDiameter;
            vocwrapper->tenseness = tenseness;
            vocwrapper->nasal = nasality;

            float temp = 0;
            for (int channel = 0; channel < channelCount; ++channel) {
                float *out = (float *)outputBufferLists[0]->mBuffers[channel].mData + frameOffset;

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

#endif
