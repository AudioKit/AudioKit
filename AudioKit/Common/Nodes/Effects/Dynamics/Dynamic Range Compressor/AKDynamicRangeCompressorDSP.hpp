//
//  AKDynamicRangeCompressorDSP.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once

#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(AUParameterAddress, AKDynamicRangeCompressorParameter) {
    AKDynamicRangeCompressorParameterRatio,
    AKDynamicRangeCompressorParameterThreshold,
    AKDynamicRangeCompressorParameterAttackTime,
    AKDynamicRangeCompressorParameterReleaseTime,
    AKDynamicRangeCompressorParameterRampDuration
};

#ifndef __cplusplus

void *createDynamicRangeCompressorDSP(int nChannels, double sampleRate);

#else

#import "AKSoundpipeDSPBase.hpp"

class AKDynamicRangeCompressorDSP : public AKSoundpipeDSPBase {
private:
    struct _Internal;
    std::unique_ptr<_Internal> _private;
 
public:
    AKDynamicRangeCompressorDSP();

    float ratioLowerBound = 0.01;
    float ratioUpperBound = 100.0;
    float thresholdLowerBound = -100.0;
    float thresholdUpperBound = 0.0;
    float attackDurationLowerBound = 0.0;
    float attackDurationUpperBound = 1.0;
    float releaseDurationLowerBound = 0.0;
    float releaseDurationUpperBound = 1.0;

    float defaultRatio = 1;
    float defaultThreshold = 0.0;
    float defaultAttackDuration = 0.1;
    float defaultReleaseDuration = 0.1;

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
