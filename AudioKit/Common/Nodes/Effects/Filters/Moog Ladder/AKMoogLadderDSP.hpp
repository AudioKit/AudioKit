//
//  AKMoogLadderDSP.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once

#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(AUParameterAddress, AKMoogLadderParameter) {
    AKMoogLadderParameterCutoffFrequency,
    AKMoogLadderParameterResonance,
    AKMoogLadderParameterRampDuration
};

#ifndef __cplusplus

AKDSPRef createMoogLadderDSP(int channelCount, double sampleRate);

#else

#import "AKSoundpipeDSPBase.hpp"

class AKMoogLadderDSP : public AKSoundpipeDSPBase {
private:
    struct InternalData;
    std::unique_ptr<InternalData> data;
 
public:
    AKMoogLadderDSP();

    float cutoffFrequencyLowerBound = 12.0;
    float cutoffFrequencyUpperBound = 20000.0;
    float resonanceLowerBound = 0.0;
    float resonanceUpperBound = 2.0;

    float defaultCutoffFrequency = 1000;
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
