//
//  AKStringResonatorDSP.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once

#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(AUParameterAddress, AKStringResonatorParameter) {
    AKStringResonatorParameterFundamentalFrequency,
    AKStringResonatorParameterFeedback,
    AKStringResonatorParameterRampDuration
};

#ifndef __cplusplus

void* createStringResonatorDSP(int nChannels, double sampleRate);

#else

#import "AKSoundpipeDSPBase.hpp"

class AKStringResonatorDSP : public AKSoundpipeDSPBase {
private:
    struct _Internal;
    std::unique_ptr<_Internal> _private;
 
public:
    AKStringResonatorDSP();
    ~AKStringResonatorDSP();

    float fundamentalFrequencyLowerBound = 12.0;
    float fundamentalFrequencyUpperBound = 10000.0;
    float feedbackLowerBound = 0.0;
    float feedbackUpperBound = 1.0;

    float defaultFundamentalFrequency = 100;
    float defaultFeedback = 0.95;

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
