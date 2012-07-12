//
//  OCSEvent.m
//  Objective-Csound
//
//  Created by Aurelius Prochazka on 7/1/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSEvent.h"

@interface OCSEvent () {
    OCSInstrument * instr;
    float dur;
}
@end


@implementation OCSEvent

@synthesize duration = dur;

- (id)initWithInstrument:(OCSInstrument *)instrument
                duration:(float)duration;
{
    self = [super init];
    if (self) {
        instr = instrument;
        dur = duration;
    }
    return self;
}


- (NSString *) description 
{
    return [NSString stringWithFormat:@"i \"%@\" 0 %0.2f", [instr uniqueName], dur];
}

@end
