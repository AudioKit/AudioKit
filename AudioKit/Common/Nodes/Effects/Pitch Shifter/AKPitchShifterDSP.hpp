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

AKDSPRef createPitchShifterDSP(int channelCount, double sampleRate);

#else

#import "AKSoundpipeDSPBase.hpp"

class AKPitchShifterDSP : public AKSoundpipeDSPBase {
private:
    struct InternalData;
    std::unique_ptr<InternalData> data;
 
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
    
    void init(int channelCount, double sampleRate) override;

    void deinit() override;

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override;
};

#endif
