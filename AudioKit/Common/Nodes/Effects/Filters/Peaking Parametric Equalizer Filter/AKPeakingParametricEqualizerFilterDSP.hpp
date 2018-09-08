//
//  AKPeakingParametricEqualizerFilterDSP.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once

#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(AUParameterAddress, AKPeakingParametricEqualizerFilterParameter) {
    AKPeakingParametricEqualizerFilterParameterCenterFrequency,
    AKPeakingParametricEqualizerFilterParameterGain,
    AKPeakingParametricEqualizerFilterParameterQ,
    AKPeakingParametricEqualizerFilterParameterRampDuration
};

#ifndef __cplusplus

void *createPeakingParametricEqualizerFilterDSP(int nChannels, double sampleRate);

#else

#import "AKSoundpipeDSPBase.hpp"

class AKPeakingParametricEqualizerFilterDSP : public AKSoundpipeDSPBase {
private:
    struct _Internal;
    std::unique_ptr<_Internal> _private;
 
public:
    AKPeakingParametricEqualizerFilterDSP();

    float centerFrequencyLowerBound = 12.0;
    float centerFrequencyUpperBound = 20000.0;
    float gainLowerBound = 0.0;
    float gainUpperBound = 10.0;
    float qLowerBound = 0.0;
    float qUpperBound = 2.0;

    float defaultCenterFrequency = 1000;
    float defaultGain = 1.0;
    float defaultQ = 0.707;

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
