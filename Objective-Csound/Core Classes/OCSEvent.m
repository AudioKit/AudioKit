//
//  OCSEvent.m
//  Objective-Csound
//
//  Created by Aurelius Prochazka on 7/1/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSEvent.h"

@interface OCSEvent () {
    OCSInstrument *instr;
    float dur;
    NSMutableArray *properties;
    NSMutableArray *values;
}
@end


@implementation OCSEvent

@synthesize duration = dur;
@synthesize instrument = templateInsrument;

- (id)initWithInstrument:(OCSInstrument *)instrument
                duration:(float)duration;
{
    self = [super init];
    if (self) {
        instr = instrument;
        dur = duration;
        properties = [[NSMutableArray alloc] init];
        values = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)setProperty:(OCSProperty *)property toValue:(float)value 
{
    [properties addObject:property];
    [values addObject:[NSNumber numberWithFloat:value]];
}

- (void)trigger 
{
    for (int i=0; i<[properties count]; i++) {
        OCSProperty *prop = [properties objectAtIndex:i];
        float val = [[values objectAtIndex:i] floatValue];
        [prop setValue:val];
    }
}


- (NSString *) description 
{
    [self trigger];
    NSString *scoreline;
    scoreline = [NSString stringWithFormat:@"i \"%@\" 0 %0.2f", [instr uniqueName], dur];
    NSLog(@"%@", scoreline);
    return scoreline;
}

@end
