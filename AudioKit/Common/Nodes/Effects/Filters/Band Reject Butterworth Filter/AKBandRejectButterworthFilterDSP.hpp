//
//  AKBandRejectButterworthFilterDSP.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once

#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(AUParameterAddress, AKBandRejectButterworthFilterParameter) {
    AKBandRejectButterworthFilterParameterCenterFrequency,
    AKBandRejectButterworthFilterParameterBandwidth,
    AKBandRejectButterworthFilterParameterRampDuration
};

#ifndef __cplusplus

void *createBandRejectButterworthFilterDSP(int nChannels, double sampleRate);

#else

#import "AKSoundpipeDSPBase.hpp"

class AKBandRejectButterworthFilterDSP : public AKSoundpipeDSPBase {
private:
    struct _Internal;
    std::unique_ptr<_Internal> _private;
 
public:
    AKBandRejectButterworthFilterDSP();

    float centerFrequencyLowerBound = 12.0;
    float centerFrequencyUpperBound = 20000.0;
    float bandwidthLowerBound = 0.0;
    float bandwidthUpperBound = 20000.0;

    float defaultCenterFrequency = 3000.0;
    float defaultBandwidth = 2000.0;

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
