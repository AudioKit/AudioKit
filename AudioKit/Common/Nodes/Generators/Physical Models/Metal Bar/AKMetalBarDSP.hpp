//
//  AKMetalBarDSP.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once

#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(AUParameterAddress, AKMetalBarParameter) {
    AKMetalBarParameterLeftBoundaryCondition,
    AKMetalBarParameterRightBoundaryCondition,
    AKMetalBarParameterDecayDuration,
    AKMetalBarParameterScanSpeed,
    AKMetalBarParameterPosition,
    AKMetalBarParameterStrikeVelocity,
    AKMetalBarParameterStrikeWidth,
    AKMetalBarParameterRampDuration
};

#ifndef __cplusplus

void *createMetalBarDSP(int nChannels, double sampleRate);

#else

#import "AKSoundpipeDSPBase.hpp"

class AKMetalBarDSP : public AKSoundpipeDSPBase {
private:
    struct _Internal;
    std::unique_ptr<_Internal> _private;
 
public:
    AKMetalBarDSP();

    float leftBoundaryConditionLowerBound = 1;
    float leftBoundaryConditionUpperBound = 3;
    float rightBoundaryConditionLowerBound = 1;
    float rightBoundaryConditionUpperBound = 3;
    float decayDurationLowerBound = 0;
    float decayDurationUpperBound = 10;
    float scanSpeedLowerBound = 0;
    float scanSpeedUpperBound = 100;
    float positionLowerBound = 0;
    float positionUpperBound = 1;
    float strikeVelocityLowerBound = 0;
    float strikeVelocityUpperBound = 1000;
    float strikeWidthLowerBound = 0;
    float strikeWidthUpperBound = 1;

    float defaultLeftBoundaryCondition = 1;
    float defaultRightBoundaryCondition = 1;
    float defaultDecayDuration = 3;
    float defaultScanSpeed = 0.25;
    float defaultPosition = 0.2;
    float defaultStrikeVelocity = 500;
    float defaultStrikeWidth = 0.05;

    float internalTrigger = 0;

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
