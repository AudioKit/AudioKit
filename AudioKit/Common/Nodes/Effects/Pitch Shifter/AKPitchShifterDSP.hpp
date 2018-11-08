//
//  AKPitchShifterDSP.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once

#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(AUParameterAddress, AKPitchShifterParameter) {
    AKPitchShifterParameterShift,
    AKPitchShifterParameterWindowSize,
    AKPitchShifterParameterCrossfade,
    AKPitchShifterParameterRampDuration
};

#ifndef __cplusplus

void *createPitchShifterDSP(int nChannels, double sampleRate);

#else

#import "AKSoundpipeDSPBase.hpp"

class AKPitchShifterDSP : public AKSoundpipeDSPBase {
private:
    struct _Internal;
    std::unique_ptr<_Internal> _private;
 
public:
    AKPitchShifterDSP();

    float shiftLowerBound = -24.0;
    float shiftUpperBound = 24.0;
    float windowSizeLowerBound = 0.0;
    float windowSizeUpperBound = 10000.0;
    float crossfadeLowerBound = 0.0;
    float crossfadeUpperBound = 10000.0;

    float defaultShift = 0;
    float defaultWindowSize = 1024;
    float defaultCrossfade = 512;

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
