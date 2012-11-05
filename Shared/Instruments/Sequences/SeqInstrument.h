//
//  SeqInstrument.h
//  OCS iPad Examples
//
//  Created by Aurelius Prochazka on 9/18/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSInstrument.h"

@interface SeqInstrument : OCSInstrument

@property (nonatomic, strong) OCSInstrumentProperty *modulation;
#define kModulationInit 1.0
#define kModulationMin  0.5
#define kModulationMax  2.0

@end

@interface SeqInstrumentNote : OCSNote

#define kFrequencyInit 220
#define kFrequencyMin  110
#define kFrequencyMax  880
@property (nonatomic, strong) OCSNoteProperty *frequency;
- (id)initWithFrequency:(float)frequency;

@end