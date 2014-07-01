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

@property (nonatomic, strong) AKNoteProperty *frequency;
- (instancetype)initWithFrequency:(float)frequency;

@end