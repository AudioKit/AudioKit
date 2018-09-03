//
//  AKFormantFilterDSP.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once

#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(AUParameterAddress, AKFormantFilterParameter) {
    AKFormantFilterParameterCenterFrequency,
    AKFormantFilterParameterAttackDuration,
    AKFormantFilterParameterDecayDuration,
    AKFormantFilterParameterRampDuration
};

#ifndef __cplusplus

void *createFormantFilterDSP(int nChannels, double sampleRate);

#else

#import "AKSoundpipeDSPBase.hpp"

class AKFormantFilterDSP : public AKSoundpipeDSPBase {
private:
    struct _Internal;
    std::unique_ptr<_Internal> _private;
 
public:
    AKFormantFilterDSP();

    float centerFrequencyLowerBound = 12.0;
    float centerFrequencyUpperBound = 20000.0;
    float attackDurationLowerBound = 0.0;
    float attackDurationUpperBound = 0.1;
    float decayDurationLowerBound = 0.0;
    float decayDurationUpperBound = 0.1;

    float defaultCenterFrequency = 1000;
    float defaultAttackDuration = 0.007;
    float defaultDecayDuration = 0.04;

    int defaultRampDurationSamples = 10000;

    // Uses the ParameterAddress as a key
    void setParameter(AUParameterAddress address, float value, bool immediate) override;

    // Uses the ParameterAddress as a key
    float getParameter(AUParameterAddress address) override;
    
    void init(int _channels, double _sampleRate) override;

    void deinit() override;

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override;
};

#endif
