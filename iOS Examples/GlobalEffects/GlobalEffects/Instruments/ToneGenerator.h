//
//  ToneGenerator.h
//  AudioKit Example
//
//  Created by Aurelius Prochazka on 6/9/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "AKFoundation.h"

@interface ToneGenerator : AKInstrument 

@property (nonatomic, strong) AKInstrumentProperty *frequency;
#define kFrequencyMin 110
#define kFrequencyMax 880

@property (readonly) AKAudio *auxilliaryOutput;

@end
