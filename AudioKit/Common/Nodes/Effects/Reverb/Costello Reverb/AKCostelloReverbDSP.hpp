//
//  AKCostelloReverbDSP.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once

#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(AUParameterAddress, AKCostelloReverbParameter) {
    AKCostelloReverbParameterFeedback,
    AKCostelloReverbParameterCutoffFrequency,
    AKCostelloReverbParameterRampDuration
};

#ifndef __cplusplus

void *createCostelloReverbDSP(int nChannels, double sampleRate);

#else

#import "AKSoundpipeDSPBase.hpp"

class AKCostelloReverbDSP : public AKSoundpipeDSPBase {
private:
    struct _Internal;
    std::unique_ptr<_Internal> _private;
 
public:
    AKCostelloReverbDSP();

    float feedbackLowerBound = 0.0;
    float feedbackUpperBound = 1.0;
    float cutoffFrequencyLowerBound = 12.0;
    float cutoffFrequencyUpperBound = 20000.0;

    float defaultFeedback = 0.6;
    float defaultCutoffFrequency = 4000.0;

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
