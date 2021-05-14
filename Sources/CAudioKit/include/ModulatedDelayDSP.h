// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#pragma once

#import <AVFoundation/AVFoundation.h>
#import "Interop.h"

typedef NS_ENUM(AUParameterAddress, ModulatedDelayParameter) {
    ModulatedDelayParameterFrequency,
    ModulatedDelayParameterDepth,
    ModulatedDelayParameterFeedback,
    ModulatedDelayParameterDryWetMix,
};

// constants
extern const float kChorus_DefaultFrequency;
extern const float kChorus_DefaultDepth;
extern const float kChorus_DefaultFeedback;
extern const float kChorus_DefaultDryWetMix;

extern const float kChorus_MinFrequency;
extern const float kChorus_MaxFrequency;
extern const float kChorus_MinFeedback;
extern const float kChorus_MaxFeedback;
extern const float kChorus_MinDepth;
extern const float kChorus_MaxDepth;
extern const float kChorus_MinDryWetMix;
extern const float kChorus_MaxDryWetMix;

extern const float kFlanger_DefaultFrequency;
extern const float kFlanger_MinFrequency;
extern const float kFlanger_MaxFrequency;
extern const float kFlanger_DefaultDepth;
extern const float kFlanger_DefaultFeedback;
extern const float kFlanger_DefaultDryWetMix;

extern const float kFlanger_MinFrequency;
extern const float kFlanger_MaxFrequency;
extern const float kFlanger_MinFeedback;
extern const float kFlanger_MaxFeedback;
extern const float kFlanger_MinDepth;
extern const float kFlanger_MaxDepth;
extern const float kFlanger_MinDryWetMix;
extern const float kFlanger_MaxDryWetMix;
