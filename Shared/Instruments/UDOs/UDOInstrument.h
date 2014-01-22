//
//  UDOInstrument.h
//  AudioKit Example
//
//  Created by Aurelius Prochazka on 6/23/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "AKFoundation.h"

@interface UDOInstrument : AKInstrument
@end

@interface UDOInstrumentNote : AKNote

#define kFrequencyInit 220
#define kFrequencyMin  110
#define kFrequencyMax  880
@property (nonatomic, strong) AKNoteProperty *frequency;
- (instancetype)initWithFrequency:(float)frequency;

@end