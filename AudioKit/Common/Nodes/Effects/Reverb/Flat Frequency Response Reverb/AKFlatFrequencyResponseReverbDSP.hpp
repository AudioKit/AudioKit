//
//  AKFlatFrequencyResponseReverbDSP.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once

#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(AUParameterAddress, AKFlatFrequencyResponseReverbParameter) {
    AKFlatFrequencyResponseReverbParameterReverbDuration,
    AKFlatFrequencyResponseReverbParameterRampDuration
};

#ifndef __cplusplus

AKDSPRef createFlatFrequencyResponseReverbDSP(int channelCount, double sampleRate);

#else

#import "AKSoundpipeDSPBase.hpp"

class AKFlatFrequencyResponseReverbDSP : public AKSoundpipeDSPBase {
private:
    struct InternalData;
    std::unique_ptr<InternalData> data;
 
public:
    AKFlatFrequencyResponseReverbDSP();

    float reverbDurationLowerBound = 0;
    float reverbDurationUpperBound = 10;

    float defaultReverbDuration = 0.5;

    int defaultRampDurationSamples = 10000;

    // Uses the ParameterAddress as a key
    void setParameter(AUParameterAddress address, float value, bool immediate) override;

    // Uses the ParameterAddress as a key
    float getParameter(AUParameterAddress address) override;
    
    void init(int channelCount, double sampleRate) override;

    void initializeConstant(float duration) override;

    void deinit() override;

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override;
};

#endif
