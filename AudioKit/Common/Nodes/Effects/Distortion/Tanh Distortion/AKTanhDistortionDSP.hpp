//
//  AKTanhDistortionDSP.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once

#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(AUParameterAddress, AKTanhDistortionParameter) {
    AKTanhDistortionParameterPregain,
    AKTanhDistortionParameterPostgain,
    AKTanhDistortionParameterPositiveShapeParameter,
    AKTanhDistortionParameterNegativeShapeParameter,
    AKTanhDistortionParameterRampTime
};

#ifndef __cplusplus

void* createTanhDistortionDSP(int nChannels, double sampleRate);

#else

#import "AKSoundpipeDSPBase.hpp"

class AKTanhDistortionDSP : public AKSoundpipeDSPBase {
private:
    struct _Internal;
    std::unique_ptr<_Internal> _private;
 
public:
    AKTanhDistortionDSP();
    ~AKTanhDistortionDSP();

    float pregainLowerBound = 0.0;
    float pregainUpperBound = 10.0;
    float postgainLowerBound = 0.0;
    float postgainUpperBound = 10.0;
    float positiveShapeParameterLowerBound = -10.0;
    float positiveShapeParameterUpperBound = 10.0;
    float negativeShapeParameterLowerBound = -10.0;
    float negativeShapeParameterUpperBound = 10.0;

    float defaultPregain = 2.0;
    float defaultPostgain = 0.5;
    float defaultPositiveShapeParameter = 0.0;
    float defaultNegativeShapeParameter = 0.0;

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
