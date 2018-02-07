//
//  AKModalResonanceFilterDSP.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once

#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(AUParameterAddress, AKModalResonanceFilterParameter) {
    AKModalResonanceFilterParameterFrequency,
    AKModalResonanceFilterParameterQualityFactor,
    AKModalResonanceFilterParameterRampTime
};

#ifndef __cplusplus

void* createModalResonanceFilterDSP(int nChannels, double sampleRate);

#else

#import "AKSoundpipeDSPBase.hpp"

class AKModalResonanceFilterDSP : public AKSoundpipeDSPBase {
private:
    struct _Internal;
    std::unique_ptr<_Internal> _private;
 
public:
    AKModalResonanceFilterDSP();
    ~AKModalResonanceFilterDSP();

    float frequencyLowerBound = 12.0;
    float frequencyUpperBound = 20000.0;
    float qualityFactorLowerBound = 0.0;
    float qualityFactorUpperBound = 100.0;

    float defaultFrequency = 500.0;
    float defaultQualityFactor = 50.0;

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
