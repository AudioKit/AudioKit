//
//  AKZitaReverbDSP.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once

#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(AUParameterAddress, AKZitaReverbParameter) {
    AKZitaReverbParameterPredelay,
    AKZitaReverbParameterCrossoverFrequency,
    AKZitaReverbParameterLowReleaseTime,
    AKZitaReverbParameterMidReleaseTime,
    AKZitaReverbParameterDampingFrequency,
    AKZitaReverbParameterEqualizerFrequency1,
    AKZitaReverbParameterEqualizerLevel1,
    AKZitaReverbParameterEqualizerFrequency2,
    AKZitaReverbParameterEqualizerLevel2,
    AKZitaReverbParameterDryWetMix,
    AKZitaReverbParameterRampDuration
};

#ifndef __cplusplus

void *createZitaReverbDSP(int nChannels, double sampleRate);

#else

#import "AKSoundpipeDSPBase.hpp"

class AKZitaReverbDSP : public AKSoundpipeDSPBase {
private:
    struct _Internal;
    std::unique_ptr<_Internal> _private;
 
public:
    AKZitaReverbDSP();

    float predelayLowerBound = 0.0;
    float predelayUpperBound = 200.0;
    float crossoverFrequencyLowerBound = 10.0;
    float crossoverFrequencyUpperBound = 1000.0;
    float lowReleaseTimeLowerBound = 0.0;
    float lowReleaseTimeUpperBound = 10.0;
    float midReleaseTimeLowerBound = 0.0;
    float midReleaseTimeUpperBound = 10.0;
    float dampingFrequencyLowerBound = 10.0;
    float dampingFrequencyUpperBound = 22050.0;
    float equalizerFrequency1LowerBound = 10.0;
    float equalizerFrequency1UpperBound = 1000.0;
    float equalizerLevel1LowerBound = -100.0;
    float equalizerLevel1UpperBound = 10.0;
    float equalizerFrequency2LowerBound = 10.0;
    float equalizerFrequency2UpperBound = 22050.0;
    float equalizerLevel2LowerBound = -100.0;
    float equalizerLevel2UpperBound = 10.0;
    float dryWetMixLowerBound = 0.0;
    float dryWetMixUpperBound = 1.0;

    float defaultPredelay = 60.0;
    float defaultCrossoverFrequency = 200.0;
    float defaultLowReleaseTime = 3.0;
    float defaultMidReleaseTime = 2.0;
    float defaultDampingFrequency = 6000.0;
    float defaultEqualizerFrequency1 = 315.0;
    float defaultEqualizerLevel1 = 0.0;
    float defaultEqualizerFrequency2 = 1500.0;
    float defaultEqualizerLevel2 = 0.0;
    float defaultDryWetMix = 1.0;

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
