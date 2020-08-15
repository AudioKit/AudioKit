// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#pragma once

#import <AVFoundation/AVFoundation.h>
#import "AKInterop.h"

typedef NS_ENUM(AUParameterAddress, AKModulatedDelayParameter) {
    AKModulatedDelayParameterFrequency,
    AKModulatedDelayParameterDepth,
    AKModulatedDelayParameterFeedback,
    AKModulatedDelayParameterDryWetMix,
};

// constants
extern const float kAKChorus_DefaultFrequency;
extern const float kAKChorus_DefaultDepth;
extern const float kAKChorus_DefaultFeedback;
extern const float kAKChorus_DefaultDryWetMix;

extern const float kAKChorus_MinFrequency;
extern const float kAKChorus_MaxFrequency;
extern const float kAKChorus_MinFeedback;
extern const float kAKChorus_MaxFeedback;
extern const float kAKChorus_MinDepth;
extern const float kAKChorus_MaxDepth;
extern const float kAKChorus_MinDryWetMix;
extern const float kAKChorus_MaxDryWetMix;

extern const float kAKFlanger_DefaultFrequency;
extern const float kAKFlanger_MinFrequency;
extern const float kAKFlanger_MaxFrequency;
extern const float kAKFlanger_DefaultDepth;
extern const float kAKFlanger_DefaultFeedback;
extern const float kAKFlanger_DefaultDryWetMix;

extern const float kAKFlanger_MinFrequency;
extern const float kAKFlanger_MaxFrequency;
extern const float kAKFlanger_MinFeedback;
extern const float kAKFlanger_MaxFeedback;
extern const float kAKFlanger_MinDepth;
extern const float kAKFlanger_MaxDepth;
extern const float kAKFlanger_MinDryWetMix;
extern const float kAKFlanger_MaxDryWetMix;

AK_API AKDSPRef akChorusCreateDSP(void);
AK_API AKDSPRef akFlangerCreateDSP(void);

#ifdef __cplusplus

#import "AKDSPBase.hpp"
#import "AKModulatedDelay.hpp"
#import "ParameterRamper.hpp"

struct AKModulatedDelayDSP : AKDSPBase
{
private:
    // ramped parameters
    ParameterRamper frequencyRamp;
    ParameterRamper depthRamp;
    ParameterRamper feedbackRamp;
    ParameterRamper dryWetMixRamp;
    AKModulatedDelay delay;

public:
    AKModulatedDelayDSP(AKModulatedDelayType type);

    void init(int channelCount, double sampleRate) override;

    void deinit() override;

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override;
};

#endif
