//
//  AKBandPassButterworthFilterDSP.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once

#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(AUParameterAddress, AKBandPassButterworthFilterParameter) {
    AKBandPassButterworthFilterParameterCenterFrequency,
    AKBandPassButterworthFilterParameterBandwidth,
    AKBandPassButterworthFilterParameterRampDuration
};

#ifndef __cplusplus

void *createBandPassButterworthFilterDSP(int nChannels, double sampleRate);

#else

#import "AKSoundpipeDSPBase.hpp"

class AKBandPassButterworthFilterDSP : public AKSoundpipeDSPBase {
private:
    struct _Internal;
    std::unique_ptr<_Internal> _private;
 
public:
    AKBandPassButterworthFilterDSP();

    float centerFrequencyLowerBound = 12.0;
    float centerFrequencyUpperBound = 20000.0;
    float bandwidthLowerBound = 0.0;
    float bandwidthUpperBound = 20000.0;

    float defaultCenterFrequency = 2000.0;
    float defaultBandwidth = 100.0;

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
