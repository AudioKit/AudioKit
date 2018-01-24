//
//  AKClarinetDSP.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once

#import <Foundation/Foundation.h>

typedef NS_ENUM(int64_t, AKClarinetParameter) {
    AKClarinetParameterFrequency,
    AKClarinetParameterAmplitude,
    AKClarinetParameterRampTime
};

#import "AKLinearParameterRamp.hpp"  // have to put this here to get it included in umbrella header

#ifndef __cplusplus

void* createClarinetDSP(int nChannels, double sampleRate);

#else

#import <AudioKit/AudioKit-Swift.h>

#include "Clarinet.h"

class AKClarinetDSP : public AKDSPBase {

private:
    float internalTrigger = 0;
    stk::Clarinet *clarinet;

    AKLinearParameterRamp frequencyRamp;
    AKLinearParameterRamp amplitudeRamp;
    AKLinearParameterRamp detuningOffsetRamp;
    AKLinearParameterRamp detuningMultiplierRamp;

public:
    AKClarinetDSP() {
        frequencyRamp.setTarget(440, true);
        frequencyRamp.setDurationInSamples(10000);
        amplitudeRamp.setTarget(1, true);
        amplitudeRamp.setDurationInSamples(10000);
    }

    /** Uses the ParameterAddress as a key */
    void setParameter(AUParameterAddress address, float value, bool immediate) override {
        switch (address) {
            case AKClarinetParameterFrequency:
                frequencyRamp.setTarget(value, immediate);
                break;
            case AKClarinetParameterAmplitude:
                amplitudeRamp.setTarget(value, immediate);
                break;
            case AKClarinetParameterRampTime:
                frequencyRamp.setRampTime(value, _sampleRate);
                amplitudeRamp.setRampTime(value, _sampleRate);
                break;
        }
    }

    /** Uses the ParameterAddress as a key */
    float getParameter(AUParameterAddress address) override {
        switch (address) {
            case AKClarinetParameterFrequency:
                return frequencyRamp.getTarget();
            case AKClarinetParameterAmplitude:
                return amplitudeRamp.getTarget();
            case AKClarinetParameterRampTime:
                return frequencyRamp.getRampTime(_sampleRate);
        }
        return 0;
    }

    void init(int _channels, double _sampleRate) override {
        AKDSPBase::init(_channels, _sampleRate);

        stk::Stk::setSampleRate(_sampleRate);
        clarinet = new stk::Clarinet(100);
    }

    void trigger() override {
        internalTrigger = 1;
    }

    void triggerFrequencyAmplitude(AUValue freq, AUValue amp) override {
        bool immediate = true;
        frequencyRamp.setTarget(freq, immediate);
        amplitudeRamp.setTarget(amp, immediate);
        trigger();
    }

    void destroy() {
        delete clarinet;
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {

        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            int frameOffset = int(frameIndex + bufferOffset);

            // do gain ramping every 8 samples
            if ((frameOffset & 0x7) == 0) {
                frequencyRamp.advanceTo(_now + frameOffset);
                amplitudeRamp.advanceTo(_now + frameOffset);
            }
            float frequency = frequencyRamp.getValue();
            float amplitude = amplitudeRamp.getValue();

            for (int channel = 0; channel < _nChannels; ++channel) {
                float* out = (float *)_outBufferListPtr->mBuffers[channel].mData + frameOffset;

                if (_playing) {
                    if (internalTrigger == 1) {
                        clarinet->noteOn(frequency, amplitude);
                    }
                } else {
                    *out = 0.0;
                }
                *out = clarinet->tick();
            }
        }
        if (internalTrigger == 1) {
            internalTrigger = 0;
        }
    }
};

#endif

