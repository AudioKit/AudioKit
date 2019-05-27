//
//  AKEqualizerFilterDSP.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once

#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(AUParameterAddress, AKEqualizerFilterParameter) {
    AKEqualizerFilterParameterCenterFrequency,
    AKEqualizerFilterParameterBandwidth,
    AKEqualizerFilterParameterGain,
    AKEqualizerFilterParameterRampDuration
};

#ifndef __cplusplus

AKDSPRef createEqualizerFilterDSP(int channelCount, double sampleRate);

#else

#import "AKSoundpipeDSPBase.hpp"

class AKEqualizerFilterDSP : public AKSoundpipeDSPBase {
private:
    struct InternalData;
    std::unique_ptr<InternalData> data;
 
public:
    AKEqualizerFilterDSP();

    float centerFrequencyLowerBound = 12.0;
    float centerFrequencyUpperBound = 20000.0;
    float bandwidthLowerBound = 0.0;
    float bandwidthUpperBound = 20000.0;
    float gainLowerBound = -100.0;
    float gainUpperBound = 100.0;

    float defaultCenterFrequency = 1000.0;
    float defaultBandwidth = 100.0;
    float defaultGain = 10.0;

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
