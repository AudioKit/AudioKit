//
//  AKDripDSP.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once

#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(AUParameterAddress, AKDripParameter) {
    AKDripParameterIntensity,
    AKDripParameterDampingFactor,
    AKDripParameterEnergyReturn,
    AKDripParameterMainResonantFrequency,
    AKDripParameterFirstResonantFrequency,
    AKDripParameterSecondResonantFrequency,
    AKDripParameterAmplitude,
    AKDripParameterRampDuration
};

#ifndef __cplusplus

void *createDripDSP(int nChannels, double sampleRate);

#else

#import "AKSoundpipeDSPBase.hpp"

class AKDripDSP : public AKSoundpipeDSPBase {
private:
    struct _Internal;
    std::unique_ptr<_Internal> _private;
    float internalTrigger = 0;

public:
    AKDripDSP();

    float intensityLowerBound = 0;
    float intensityUpperBound = 100;
    float dampingFactorLowerBound = 0.0;
    float dampingFactorUpperBound = 2.0;
    float energyReturnLowerBound = 0;
    float energyReturnUpperBound = 100;
    float mainResonantFrequencyLowerBound = 0;
    float mainResonantFrequencyUpperBound = 22000;
    float firstResonantFrequencyLowerBound = 0;
    float firstResonantFrequencyUpperBound = 22000;
    float secondResonantFrequencyLowerBound = 0;
    float secondResonantFrequencyUpperBound = 22000;
    float amplitudeLowerBound = 0;
    float amplitudeUpperBound = 1;

    float defaultIntensity = 10;
    float defaultDampingFactor = 0.2;
    float defaultEnergyReturn = 0;
    float defaultMainResonantFrequency = 450;
    float defaultFirstResonantFrequency = 600;
    float defaultSecondResonantFrequency = 750;
    float defaultAmplitude = 0.3;

    int defaultRampDurationSamples = 10000;

    // Uses the ParameterAddress as a key
    void setParameter(AUParameterAddress address, float value, bool immediate) override;

    // Uses the ParameterAddress as a key
    float getParameter(AUParameterAddress address) override;
    
    void init(int _channels, double _sampleRate) override;

    void deinit() override;

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override;

    void trigger() override;
};

#endif
