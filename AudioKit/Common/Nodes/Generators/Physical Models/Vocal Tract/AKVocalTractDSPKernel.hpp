//
//  AKVocalTractDSPKernel.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

#pragma once

#import "DSPKernel.hpp"
#import "ParameterRamper.hpp"

#import <AudioKit/AudioKit-Swift.h>

extern "C" {
#include "soundpipe.h"
#include "vocwrapper.h"
}

enum {
    frequencyAddress = 0,
    tonguePositionAddress = 1,
    tongueDiameterAddress = 2,
    tensenessAddress = 3,
    nasalityAddress = 4
};

class AKVocalTractDSPKernel : public AKSoundpipeKernel, public AKBuffered {
public:
    // MARK: Member Functions

    AKVocalTractDSPKernel() {}

    void init(int _channels, double _sampleRate) override {
        AKSoundpipeKernel::init(_channels, _sampleRate);

        sp_vocwrapper_create(&vocwrapper0);
        sp_vocwrapper_create(&vocwrapper1);
        sp_vocwrapper_init(sp, vocwrapper0);
        sp_vocwrapper_init(sp, vocwrapper1);
        vocwrapper0->freq = 160.0;
        vocwrapper1->freq = 160.0;
        vocwrapper0->pos = 0.5;
        vocwrapper1->pos = 0.5;
        vocwrapper0->diam = 1.0;
        vocwrapper1->diam = 1.0;
        vocwrapper0->tenseness = 0.6;
        vocwrapper1->tenseness = 0.6;
        vocwrapper0->nasal = 0.0;
        vocwrapper1->nasal = 0.0;

        frequencyRamper.init();
        tonguePositionRamper.init();
        tongueDiameterRamper.init();
        tensenessRamper.init();
        nasalityRamper.init();
    }

    void start() {
        started = true;
    }

    void stop() {
        started = false;
    }

    void destroy() {
        sp_vocwrapper_destroy(&vocwrapper0);
        sp_vocwrapper_destroy(&vocwrapper1);
        AKSoundpipeKernel::destroy();
    }

    void reset() {
        resetted = true;
        frequencyRamper.reset();
        tonguePositionRamper.reset();
        tongueDiameterRamper.reset();
        tensenessRamper.reset();
        nasalityRamper.reset();
    }

    void setFrequency(float value) {
        frequency = clamp(value, 0.0f, 22050.0f);
        frequencyRamper.setImmediate(frequency);
    }

    void setTonguePosition(float value) {
        tonguePosition = clamp(value, 0.0f, 1.0f);
        tonguePositionRamper.setImmediate(tonguePosition);
    }

    void setTongueDiameter(float value) {
        tongueDiameter = clamp(value, 0.0f, 1.0f);
        tongueDiameterRamper.setImmediate(tongueDiameter);
    }

    void setTenseness(float value) {
        tenseness = clamp(value, 0.0f, 1.0f);
        tensenessRamper.setImmediate(tenseness);
    }

    void setNasality(float value) {
        nasality = clamp(value, 0.0f, 1.0f);
        nasalityRamper.setImmediate(nasality);
    }


    void setParameter(AUParameterAddress address, AUValue value) {
        switch (address) {
            case frequencyAddress:
                frequencyRamper.setUIValue(clamp(value, 0.0f, 22050.0f));
                break;

            case tonguePositionAddress:
                tonguePositionRamper.setUIValue(clamp(value, 0.0f, 1.0f));
                break;

            case tongueDiameterAddress:
                tongueDiameterRamper.setUIValue(clamp(value, 0.0f, 1.0f));
                break;

            case tensenessAddress:
                tensenessRamper.setUIValue(clamp(value, 0.0f, 1.0f));
                break;

            case nasalityAddress:
                nasalityRamper.setUIValue(clamp(value, 0.0f, 1.0f));
                break;

        }
    }

    AUValue getParameter(AUParameterAddress address) {
        switch (address) {
            case frequencyAddress:
                return frequencyRamper.getUIValue();

            case tonguePositionAddress:
                return tonguePositionRamper.getUIValue();

            case tongueDiameterAddress:
                return tongueDiameterRamper.getUIValue();

            case tensenessAddress:
                return tensenessRamper.getUIValue();

            case nasalityAddress:
                return nasalityRamper.getUIValue();

            default: return 0.0f;
        }
    }

    void startRamp(AUParameterAddress address, AUValue value, AUAudioFrameCount duration) override {
        switch (address) {
            case frequencyAddress:
                frequencyRamper.startRamp(clamp(value, 0.0f, 22050.0f), duration);
                break;

            case tonguePositionAddress:
                tonguePositionRamper.startRamp(clamp(value, 0.0f, 1.0f), duration);
                break;

            case tongueDiameterAddress:
                tongueDiameterRamper.startRamp(clamp(value, 0.0f, 1.0f), duration);
                break;

            case tensenessAddress:
                tensenessRamper.startRamp(clamp(value, 0.0f, 1.0f), duration);
                break;

            case nasalityAddress:
                nasalityRamper.startRamp(clamp(value, 0.0f, 1.0f), duration);
                break;

        }
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {

        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {

            int frameOffset = int(frameIndex + bufferOffset);

            frequency = frequencyRamper.getAndStep();
            vocwrapper0->freq = (float)frequency;
            vocwrapper1->freq = (float)frequency;
            tonguePosition = tonguePositionRamper.getAndStep();
            vocwrapper0->pos = (float)tonguePosition;
            vocwrapper1->pos = (float)tonguePosition;
            tongueDiameter = tongueDiameterRamper.getAndStep();
            vocwrapper0->diam = (float)tongueDiameter;
            vocwrapper1->diam = (float)tongueDiameter;
            tenseness = tensenessRamper.getAndStep();
            vocwrapper0->tenseness = (float)tenseness;
            vocwrapper1->tenseness = (float)tenseness;
            nasality = nasalityRamper.getAndStep();
            vocwrapper0->nasal = (float)nasality;
            vocwrapper1->nasal = (float)nasality;

            for (int channel = 0; channel < channels; ++channel) {

                float *out = (float *)outBufferListPtr->mBuffers[channel].mData + frameOffset;

                if (started) {
                    if (channel == 0) {
                        sp_vocwrapper_compute(sp, vocwrapper0, NULL, out);
                    } else {
                        sp_vocwrapper_compute(sp, vocwrapper1, NULL, out);
                    }
                } else {
                    *out = 0.0f;
                }
            }
        }
    }

    // MARK: Member Variables

private:

    sp_vocwrapper *vocwrapper0;
    sp_vocwrapper *vocwrapper1;

    float frequency = 160.0;
    float tonguePosition = 0.5;
    float tongueDiameter = 1.0;
    float tenseness = 0.6;
    float nasality = 0.0;

public:
    bool started = true;
    bool resetted = false;
    ParameterRamper frequencyRamper = 160.0;
    ParameterRamper tonguePositionRamper = 0.5;
    ParameterRamper tongueDiameterRamper = 1.0;
    ParameterRamper tensenessRamper = 0.6;
    ParameterRamper nasalityRamper = 0.0;
};
