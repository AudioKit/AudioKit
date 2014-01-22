//
//  TweakableInstrument.h
//  AudioKit Example
//
//  Created by Adam Boulanger on 6/18/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "AKFoundation.h"

@interface TweakableInstrument : AKInstrument

@property (nonatomic, strong) AKInstrumentProperty *amplitude;
#define kTweakableAmplitudeInit 0.1
#define kTweakableAmplitudeMin  0.0
#define kTweakableAmplitudeMax  0.3

@property (nonatomic, strong) AKInstrumentProperty *frequency;
#define kTweakableFrequencyInit 220
#define kTweakableFrequencyMin  110
#define kTweakableFrequencyMax  880

@property (nonatomic, strong) AKInstrumentProperty *modulation;
#define kTweakableModulationInit 0.5
#define kTweakableModulationMin  0.25
#define kTweakableModulationMax  2.2

@property (nonatomic, strong) AKInstrumentProperty *modIndex;
#define kTweakableModIndexInit 1.0
#define kTweakableModIndexMin  0.0
#define kTweakableModIndexMax 25.0

@end
