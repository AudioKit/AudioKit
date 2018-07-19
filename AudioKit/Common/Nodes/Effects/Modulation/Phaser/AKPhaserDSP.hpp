//
//  AKPhaserDSP.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once

#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(AUParameterAddress, AKPhaserParameter) {
    AKPhaserParameterNotchMinimumFrequency,
    AKPhaserParameterNotchMaximumFrequency,
    AKPhaserParameterNotchWidth,
    AKPhaserParameterNotchFrequency,
    AKPhaserParameterVibratoMode,
    AKPhaserParameterDepth,
    AKPhaserParameterFeedback,
    AKPhaserParameterInverted,
    AKPhaserParameterLfoBPM,
    AKPhaserParameterRampDuration
};

#ifndef __cplusplus

void* createPhaserDSP(int nChannels, double sampleRate);

#else

#import "AKSoundpipeDSPBase.hpp"

class AKPhaserDSP : public AKSoundpipeDSPBase {
private:
    struct _Internal;
    std::unique_ptr<_Internal> _private;
 
public:
    AKPhaserDSP();
    ~AKPhaserDSP();

    float notchMinimumFrequencyLowerBound = 20;
    float notchMinimumFrequencyUpperBound = 5000;
    float notchMaximumFrequencyLowerBound = 20;
    float notchMaximumFrequencyUpperBound = 10000;
    float notchWidthLowerBound = 10;
    float notchWidthUpperBound = 5000;
    float notchFrequencyLowerBound = 1.1;
    float notchFrequencyUpperBound = 4.0;
    float vibratoModeLowerBound = 0;
    float vibratoModeUpperBound = 1;
    float depthLowerBound = 0;
    float depthUpperBound = 1;
    float feedbackLowerBound = 0;
    float feedbackUpperBound = 1;
    float invertedLowerBound = 0;
    float invertedUpperBound = 1;
    float lfoBPMLowerBound = 24;
    float lfoBPMUpperBound = 360;

    float defaultNotchMinimumFrequency = 100;
    float defaultNotchMaximumFrequency = 800;
    float defaultNotchWidth = 1000;
    float defaultNotchFrequency = 1.5;
    float defaultVibratoMode = 1;
    float defaultDepth = 1;
    float defaultFeedback = 0;
    float defaultInverted = 0;
    float defaultLfoBPM = 30;

    int defaultRampDurationSamples = 10000;

    // Uses the ParameterAddress as a key
    void setParameter(AUParameterAddress address, float value, bool immediate) override;

    // Uses the ParameterAddress as a key
    float getParameter(AUParameterAddress address) override;
    
    void init(int _channels, double _sampleRate) override;

    void destroy();

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override;
};

#endif
