//
//  OCSEvent.h
//  Objective-Csound
//
//  Created by Aurelius Prochazka on 7/1/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSInstrument.h"

@interface OCSEvent : NSObject

@property (readonly) float duration;

- (id)initWithInstrument:(OCSInstrument *)instrument
                duration:(float)duration;

- (id)initWithProperty:(OCSProperty *)property
                 value:(float)value;

- (void)triggerInstrument:(OCSInstrument *)instrument
                 duration:(float)duration;

- (void)setProperty:(OCSProperty *)property 
            toValue:(float)value; 

- (void)play;
- (void)setProperties;
- (NSString *)stringForCSD;

@end
