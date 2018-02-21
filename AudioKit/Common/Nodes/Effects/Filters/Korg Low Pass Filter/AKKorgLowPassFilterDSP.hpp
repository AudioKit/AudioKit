//
//  AKKorgLowPassFilterDSP.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once

#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(AUParameterAddress, AKKorgLowPassFilterParameter) {
    AKKorgLowPassFilterParameterCutoffFrequency,
    AKKorgLowPassFilterParameterResonance,
    AKKorgLowPassFilterParameterSaturation,
    AKKorgLowPassFilterParameterRampTime
};

#ifndef __cplusplus

void* createKorgLowPassFilterDSP(int nChannels, double sampleRate);

#else

#import "AKSoundpipeDSPBase.hpp"

class AKKorgLowPassFilterDSP : public AKSoundpipeDSPBase {
private:
    struct _Internal;
    std::unique_ptr<_Internal> _private;
 
public:
    AKKorgLowPassFilterDSP();
    ~AKKorgLowPassFilterDSP();

    float cutoffFrequencyLowerBound = 0.0;
    float cutoffFrequencyUpperBound = 22050.0;
    float resonanceLowerBound = 0.0;
    float resonanceUpperBound = 2.0;
    float saturationLowerBound = 0.0;
    float saturationUpperBound = 10.0;

    float defaultCutoffFrequency = 1000.0;
    float defaultResonance = 1.0;
    float defaultSaturation = 0.0;

    int defaultRampTimeSamples = 10000;

    // Uses the ParameterAddress as a key
    void setParameter(AUParameterAddress address, float value, bool immediate) override;

    // Uses the ParameterAddress as a key
    float getParameter(AUParameterAddress address) override;
    
    void init(int _channels, double _sampleRate) override;

    void destroy();

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override;
};

#endif
