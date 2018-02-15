//
//  AKPinkNoiseDSP.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once

#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(AUParameterAddress, AKPinkNoiseParameter) {
    AKPinkNoiseParameterAmplitude,
    AKPinkNoiseParameterRampTime
};

#ifndef __cplusplus

void* createPinkNoiseDSP(int nChannels, double sampleRate);

#else

#import "AKSoundpipeDSPBase.hpp"

class AKPinkNoiseDSP : public AKSoundpipeDSPBase {
private:
    struct _Internal;
    std::unique_ptr<_Internal> _private;
 
public:
    AKPinkNoiseDSP();
    ~AKPinkNoiseDSP();

    float amplitudeLowerBound = 0.0;
    float amplitudeUpperBound = 1.0;

    float defaultAmplitude = 1.0;

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
