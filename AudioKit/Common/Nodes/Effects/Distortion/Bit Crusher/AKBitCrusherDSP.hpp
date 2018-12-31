//
//  AKBitCrusherDSP.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once

#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(AUParameterAddress, AKBitCrusherParameter) {
    AKBitCrusherParameterBitDepth,
    AKBitCrusherParameterSampleRate,
    AKBitCrusherParameterRampDuration
};

#ifndef __cplusplus

AKDSPRef createBitCrusherDSP(int channelCount, double sampleRate);

#else

#import "AKSoundpipeDSPBase.hpp"

class AKBitCrusherDSP : public AKSoundpipeDSPBase {
private:
    struct InternalData;
    std::unique_ptr<InternalData> data;
 
public:
    AKBitCrusherDSP();

    float bitDepthLowerBound = 1;
    float bitDepthUpperBound = 24;
    float sampleRateLowerBound = 0.0;
    float sampleRateUpperBound = 20000.0;

    float defaultBitDepth = 8;
    float defaultSampleRate = 10000;

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
