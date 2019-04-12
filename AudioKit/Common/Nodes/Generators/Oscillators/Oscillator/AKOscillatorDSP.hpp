//
//  AKOscillatorDSP.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once

#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(AUParameterAddress, AKOscillatorParameter) {
    AKOscillatorParameterFrequency,
    AKOscillatorParameterAmplitude,
    AKOscillatorParameterDetuningOffset,
    AKOscillatorParameterDetuningMultiplier,
    AKOscillatorParameterRampDuration
};

#ifndef __cplusplus

AKDSPRef createOscillatorDSP(int channelCount, double sampleRate);

#else

#import "AKSoundpipeDSPBase.hpp"

class AKOscillatorDSP : public AKSoundpipeDSPBase {
private:
    struct InternalData;
    std::unique_ptr<InternalData> data;
 
public:
    AKOscillatorDSP();

    float frequencyLowerBound = 0.0;
    float frequencyUpperBound = 20000.0;
    float amplitudeLowerBound = 0.0;
    float amplitudeUpperBound = 10.0;
    float detuningOffsetLowerBound = -1000.0;
    float detuningOffsetUpperBound = 1000.0;
    float detuningMultiplierLowerBound = 0.9;
    float detuningMultiplierUpperBound = 1.11;

    float defaultFrequency = 440.0;
    float defaultAmplitude = 1.0;
    float defaultDetuningOffset = 0.0;
    float defaultDetuningMultiplier = 1.0;

    int defaultRampDurationSamples = 10000;

    // Uses the ParameterAddress as a key
    void setParameter(AUParameterAddress address, float value, bool immediate) override;

    // Uses the ParameterAddress as a key
    float getParameter(AUParameterAddress address) override;
    
    void init(int channelCount, double sampleRate) override;

    void deinit() override;

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override;

    // Generator Stuff
    void setupWaveform(uint32_t size) override;
    void setWaveformValue(uint32_t index, float value) override;
};

#endif
