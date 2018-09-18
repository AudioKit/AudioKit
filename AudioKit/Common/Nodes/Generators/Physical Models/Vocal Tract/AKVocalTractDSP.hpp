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

void *createVocalTractDSP(int nChannels, double sampleRate);

#else

#import "AKSoundpipeDSPBase.hpp"

class AKVocalTractDSP : public AKSoundpipeDSPBase {

    sp_vocwrapper *_vocwrapper;

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
                frequencyRamp.setRampDuration(value, _sampleRate);
                tonguePositionRamp.setRampDuration(value, _sampleRate);
                tongueDiameterRamp.setRampDuration(value, _sampleRate);
                tensenessRamp.setRampDuration(value, _sampleRate);
                nasalityRamp.setRampDuration(value, _sampleRate);
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
                return frequencyRamp.getRampDuration(_sampleRate);
        }
        return 0;
    }

    void init(int _channels, double _sampleRate) override {
        AKSoundpipeDSPBase::init(_channels, _sampleRate);

        sp_vocwrapper_create(&_vocwrapper);
        sp_vocwrapper_init(_sp, _vocwrapper);
        _vocwrapper->freq = 160.0;
        _vocwrapper->pos = 0.5;
        _vocwrapper->diam = 1.0;
        _vocwrapper->tenseness = 0.6;
        _vocwrapper->nasal = 0.0;
    }

    void deinit() override {
        sp_vocwrapper_destroy(&_vocwrapper);
    }


    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {

        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            int frameOffset = int(frameIndex + bufferOffset);

            // do ramping every 8 samples
            if ((frameOffset & 0x7) == 0) {
                frequencyRamp.advanceTo(_now + frameOffset);
                tonguePositionRamp.advanceTo(_now + frameOffset);
                tongueDiameterRamp.advanceTo(_now + frameOffset);
                tensenessRamp.advanceTo(_now + frameOffset);
                nasalityRamp.advanceTo(_now + frameOffset);
            }
            float frequency = frequencyRamp.getValue();
            float tonguePosition = tonguePositionRamp.getValue();
            float tongueDiameter = tongueDiameterRamp.getValue();
            float tenseness = tensenessRamp.getValue();
            float nasality = nasalityRamp.getValue();
            _vocwrapper->freq = frequency;
            _vocwrapper->pos = tonguePosition;
            _vocwrapper->diam = tongueDiameter;
            _vocwrapper->tenseness = tenseness;
            _vocwrapper->nasal = nasality;

            float temp = 0;
            for (int channel = 0; channel < _nChannels; ++channel) {
                float *out = (float *)_outBufferListPtr->mBuffers[channel].mData + frameOffset;

                if (_playing) {
                    if (channel == 0) {
                        sp_vocwrapper_compute(_sp, _vocwrapper, nil, &temp);
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
