//
//  AKModulatedDelayDSP.hpp
//  AudioKit
//
//  Created by Shane Dunne, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once

#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(AUParameterAddress, AKModulatedDelayParameter) {
    AKModulatedDelayParameterFrequency,
    AKModulatedDelayParameterDepth,
    AKModulatedDelayParameterFeedback,
    AKModulatedDelayParameterDryWetMix,
    AKModulatedDelayParameterRampDuration
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

#ifndef __cplusplus

void *createChorusDSP(int nChannels, double sampleRate);
void *createFlangerDSP(int nChannels, double sampleRate);

#else

#import "AKModulatedDelay.hpp"
#import "AKLinearParameterRamp.hpp"

struct AKModulatedDelayDSP : AKDSPBase, AKModulatedDelay
{
    // ramped parameters
    AKLinearParameterRamp frequencyRamp;
    AKLinearParameterRamp depthRamp;
    AKLinearParameterRamp feedbackRamp;
    AKLinearParameterRamp dryWetMixRamp;
    
    AKModulatedDelayDSP(AKModulatedDelayType type);
    
    void init(int nChannels, double sampleRate) override;
    void deinit() override;
    
    void setParameter(uint64_t address, float value, bool immediate) override;
    float getParameter(uint64_t address) override;
    
    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override;
};

#endif
