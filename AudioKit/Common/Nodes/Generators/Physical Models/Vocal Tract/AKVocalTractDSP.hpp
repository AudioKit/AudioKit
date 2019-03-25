//
//  AKVocalTractDSP.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once

#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(AUParameterAddress, AKVocalTractParameter) {
    AKVocalTractParameterFrequency,
    AKVocalTractParameterTonguePosition,
    AKVocalTractParameterTongueDiameter,
    AKVocalTractParameterTenseness,
    AKVocalTractParameterNasality,
    AKVocalTractParameterRampDuration
};

#import "AKLinearParameterRamp.hpp"  // have to put this here to get it included in umbrella header

#ifndef __cplusplus

AKDSPRef createVocalTractDSP(int channelCount, double sampleRate);

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
        frequencyRamp.setTarget(160.0, true);
        frequencyRamp.setDurationInSamples(10000);
        tonguePositionRamp.setTarget(0.5, true);
        tonguePositionRamp.setDurationInSamples(10000);
        tongueDiameterRamp.setTarget(1.0, true);
        tongueDiameterRamp.setDurationInSamples(10000);
        tensenessRamp.setTarget(0.6, true);
        tensenessRamp.setDurationInSamples(10000);
        nasalityRamp.setTarget(0.0, true);
        nasalityRamp.setDurationInSamples(10000);
    }

    /** Uses the ParameterAddress as a key */
    void setParameter(AUParameterAddress address, float value, bool immediate) override {
        switch (address) {
            case AKVocalTractParameterFrequency:
                frequencyRamp.setTarget(value, immediate);
                break;
            case AKVocalTractParameterTonguePosition:
                tonguePositionRamp.setTarget(value, immediate);
                break;
            case AKVocalTractParameterTongueDiameter:
                tongueDiameterRamp.setTarget(value, immediate);
                break;
            case AKVocalTractParameterTenseness:
                tensenessRamp.setTarget(value, immediate);
                break;
            case AKVocalTractParameterNasality:
                nasalityRamp.setTarget(value, immediate);
                break;
            case AKVocalTractParameterRampDuration:
                frequencyRamp.setRampDuration(value, sampleRate);
                tonguePositionRamp.setRampDuration(value, sampleRate);
                tongueDiameterRamp.setRampDuration(value, sampleRate);
                tensenessRamp.setRampDuration(value, sampleRate);
                nasalityRamp.setRampDuration(value, sampleRate);
                break;
        }
    }

    /** Uses the ParameterAddress as a key */
    float getParameter(AUParameterAddress address) override {
        switch (address) {
            case AKVocalTractParameterFrequency:
                return frequencyRamp.getTarget();
            case AKVocalTractParameterTonguePosition:
                return tonguePositionRamp.getTarget();
            case AKVocalTractParameterTongueDiameter:
                return tongueDiameterRamp.getTarget();
            case AKVocalTractParameterTenseness:
                return tensenessRamp.getTarget();
            case AKVocalTractParameterNasality:
                return nasalityRamp.getTarget();
            case AKVocalTractParameterRampDuration:
                return frequencyRamp.getRampDuration(sampleRate);
        }
        return 0;
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
                float *out = (float *)outBufferListPtr->mBuffers[channel].mData + frameOffset;

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
