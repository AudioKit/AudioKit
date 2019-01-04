//
//  AKStereoDelayDSP.hpp
//  AudioKit
//
//  Created by Shane Dunne, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once

#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(AUParameterAddress, AKStereoDelayParameter) {
    AKStereoDelayParameterTime,
    AKStereoDelayParameterFeedback,
    AKStereoDelayParameterDryWetMix,
    AKStereoDelayParameterPingPong,
    AKStereoDelayParameterRampDuration
};

#ifndef __cplusplus

AKDSPRef createStereoDelayDSP(int channelCount, double sampleRate);

#else

#import "AKLinearParameterRamp.hpp"

class AKStereoDelayDSP : public AKDSPBase
{
private:
    struct InternalData;
    std::unique_ptr<InternalData> data;
 
public:
    AKStereoDelayDSP();

    float timeLowerBound = 0;
    float timeUpperBound = 2;
    float feedbackLowerBound = 0;
    float feedbackUpperBound = 1;
    float dryWetMixLowerBound = 0;
    float dryWetMixUpperBound = 1;

    float defaultTime = 0.5;
    float defaultFeedback = 0;
    float defaultDryWetMix = 0.5;
    bool defaultPingPong = false;

    int defaultRampDurationSamples = 10000;

    // Uses the ParameterAddress as a key
    void setParameter(AUParameterAddress address, float value, bool immediate) override;

    // Uses the ParameterAddress as a key
    float getParameter(AUParameterAddress address) override;
    
    void init(int channelCount, double sampleRate) override;
    void clear() override;
    void deinit() override;

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override;
};

#endif
