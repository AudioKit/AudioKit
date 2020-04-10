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
    AKModalResonanceFilterParameterRampDuration
};

#ifndef __cplusplus

AKDSPRef createModalResonanceFilterDSP(void);

#else

#import "AKSoundpipeDSPBase.hpp"

class AKModalResonanceFilterDSP : public AKSoundpipeDSPBase {
private:
    struct InternalData;
    std::unique_ptr<InternalData> data;
 
public:
    AKModalResonanceFilterDSP();

    float frequencyLowerBound = 12.0;
    float frequencyUpperBound = 20000.0;
    float qualityFactorLowerBound = 0.0;
    float qualityFactorUpperBound = 100.0;

    float defaultFrequency = 500.0;
    float defaultQualityFactor = 50.0;

    int defaultRampDurationSamples = 10000;

    // Uses the ParameterAddress as a key
    void setParameter(AUParameterAddress address, float value, bool immediate) override;

    // Uses the ParameterAddress as a key
    float getParameter(AUParameterAddress address) override;
    
    void init(int channelCount, double sampleRate) override;

    void deinit() override;

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override;
};

#endif
