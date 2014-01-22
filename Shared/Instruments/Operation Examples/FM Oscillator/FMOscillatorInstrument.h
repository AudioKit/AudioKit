//
//  FMOscillatorInstrument.h
//  AudioKit Example
//
//  Created by Aurelius Prochazka on 9/2/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "AKFoundation.h"

@interface FMOscillatorInstrument : AKInstrument

@property (nonatomic, strong) AKInstrumentProperty *frequency;
#define kFrequencyInit 440
#define kFrequencyMin  20
#define kFrequencyMax  20000

@property (nonatomic, strong) AKInstrumentProperty *amplitude;
#define kAmplitudeInit 0.2
#define kAmplitudeMin  0
#define kAmplitudeMax  1

@property (nonatomic, strong) AKInstrumentProperty *carrierMultiplier;
#define kCarrierMultiplierInit 1.0
#define kCarrierMultiplierMin  0.0
#define kCarrierMultiplierMax  3.0

@property (nonatomic, strong) AKInstrumentProperty *modulatingMultiplier;
#define kModulatingMultiplierInit 1.0
#define kModulatingMultiplierMin 0.0
#define kModulatingMultiplierMax 3.0

@property (nonatomic, strong) AKInstrumentProperty *modulationIndex;
#define kModulationIndexInit 15
#define kModulationIndexMin   0
#define kModulationIndexMax  30

@end
