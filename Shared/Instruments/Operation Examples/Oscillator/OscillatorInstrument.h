//
//  OscillatorInstrument.h
//  AKiPad
//
//  Created by Aurelius Prochazka on 8/30/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "AKFoundation.h"

@interface OscillatorInstrument : AKInstrument

@property (nonatomic, strong) AKInstrumentProperty *frequency;
#define kFrequencyInit 440
#define kFrequencyMin  110
#define kFrequencyMax  880

@property (nonatomic, strong) AKInstrumentProperty *amplitude;
#define kAmplitudeInit 0.2
#define kAmplitudeMin  0
#define kAmplitudeMax  1

@end
