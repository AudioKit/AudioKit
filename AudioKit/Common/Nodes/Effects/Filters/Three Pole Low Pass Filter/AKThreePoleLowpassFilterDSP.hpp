//
//  AKThreePoleLowpassFilterDSP.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once

#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(AUParameterAddress, AKThreePoleLowpassFilterParameter) {
    AKThreePoleLowpassFilterParameterDistortion,
    AKThreePoleLowpassFilterParameterCutoffFrequency,
    AKThreePoleLowpassFilterParameterResonance,
    AKThreePoleLowpassFilterParameterRampDuration
};

#ifndef __cplusplus

AKDSPRef createThreePoleLowpassFilterDSP(int channelCount, double sampleRate);

#else

#import "AKSoundpipeDSPBase.hpp"

class AKThreePoleLowpassFilterDSP : public AKSoundpipeDSPBase {
private:
    struct InternalData;
    std::unique_ptr<InternalData> data;
 
public:
    AKThreePoleLowpassFilterDSP();

    float distortionLowerBound = 0.0;
    float distortionUpperBound = 2.0;
    float cutoffFrequencyLowerBound = 12.0;
    float cutoffFrequencyUpperBound = 20000.0;
    float resonanceLowerBound = 0.0;
    float resonanceUpperBound = 2.0;

    float defaultDistortion = 0.5;
    float defaultCutoffFrequency = 1500;
    float defaultResonance = 0.5;

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
