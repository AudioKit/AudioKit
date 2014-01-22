//
//  SeqInstrument.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 9/18/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "AKFoundation.h"

@interface SeqInstrument : AKInstrument

@property (nonatomic, strong) AKInstrumentProperty *modulation;
#define kModulationInit 1.0
#define kModulationMin  0.5
#define kModulationMax  2.0

@end

@interface SeqInstrumentNote : AKNote

#define kFrequencyInit 220
#define kFrequencyMin  110
#define kFrequencyMax  880
@property (nonatomic, strong) AKNoteProperty *frequency;
- (instancetype)initWithFrequency:(float)frequency;

@end