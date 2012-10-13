//
//  UDOInstrument.h
//  Objective-C Sound Example
//
//  Created by Aurelius Prochazka on 6/23/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSInstrument.h"

@class UDOInstrumentNote;

@interface UDOInstrument : OCSInstrument

- (UDOInstrumentNote *)createNote;

@end

@interface UDOInstrumentNote : OCSNote

@property (nonatomic, strong) OCSNoteProperty *frequency;
#define kFrequencyInit 220
#define kFrequencyMin  110
#define kFrequencyMax  880

@end