//
//  TweakableInstrument.h
//  Objective-C Sound Example
//
//  Created by Adam Boulanger on 6/18/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSInstrument.h"

@interface TweakableInstrument : OCSInstrument

@property (nonatomic, strong) OCSInstrumentProperty *amplitude;
#define kTweakableAmplitudeInit 0.1
#define kTweakableAmplitudeMin  0.0
#define kTweakableAmplitudeMax  0.3

@property (nonatomic, strong) OCSInstrumentProperty *frequency;
#define kTweakableFrequencyInit 220
#define kTweakableFrequencyMin  110
#define kTweakableFrequencyMax  880

@property (nonatomic, strong) OCSInstrumentProperty *modulation;
#define kTweakableModulationInit 0.5
#define kTweakableModulationMin  0.25
#define kTweakableModulationMax  2.2

@property (nonatomic, strong) OCSInstrumentProperty *modIndex;
#define kTweakableModIndexInit 1.0
#define kTweakableModIndexMin  0.0
#define kTweakableModIndexMax 25.0

@end
