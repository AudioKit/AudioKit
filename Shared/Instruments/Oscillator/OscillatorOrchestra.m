//
//  OscillatorOrchestra.m
//  OCSiPad
//
//  Created by Aurelius Prochazka on 8/30/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OscillatorOrchestra.h"


@implementation OscillatorOrchestra

@synthesize instrument = _instrument;

- (id)init
{
    self = [super init];
    if (self) {
        _instrument = [[OscillatorInstrument alloc] init];
        [self addInstrument:_instrument];
    }
    return self;
}

@end
