//
//  AKVariableDelayDSP.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once

#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(AUParameterAddress, AKVariableDelayParameter) {
    AKVariableDelayParameterTime,
    AKVariableDelayParameterFeedback,
    AKVariableDelayParameterRampDuration
};

#ifndef __cplusplus

void *createVariableDelayDSP(int nChannels, double sampleRate);

#else

#import "AKSoundpipeDSPBase.hpp"

class AKVariableDelayDSP : public AKSoundpipeDSPBase {
private:
    struct _Internal;
    std::unique_ptr<_Internal> _private;
 
public:
    AKVariableDelayDSP();

    float timeLowerBound = 0;
    float timeUpperBound = 10;
    float feedbackLowerBound = 0;
    float feedbackUpperBound = 1;

    float defaultTime = 0;
    float defaultFeedback = 0;

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
