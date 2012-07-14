//
//  OCSEvent.m
//  Objective-Csound
//
//  Created by Aurelius Prochazka on 7/1/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSEvent.h"
#import "OCSManager.h"

@interface OCSEvent () {
    float maxDuration;
    NSMutableString *scoreLines;
    NSMutableArray *properties;
    NSMutableArray * values;
}
@end


@implementation OCSEvent
@synthesize duration = maxDuration;

- (id)init {
    self = [super init];
    if (self) {
        maxDuration = 0;
        scoreLines = [[NSMutableString alloc] init];
        properties = [[NSMutableArray alloc] init];
        values     = [[NSMutableArray alloc] init];
    }
    return self;
}

- (id)initWithInstrument:(OCSInstrument *)instrument
                duration:(float)duration;
{
    self = [self init];
    if (self) {
        maxDuration = duration;
        [self triggerInstrument:instrument duration:duration];
    }
    return self;
}

- (id)initWithProperty:(OCSProperty *)property
                 value:(float)value;
{
    self = [self init];
    if (self) {
        [self setProperty:property toValue:value];
    }
    return self;
}

- (void)triggerInstrument:(OCSInstrument *)instrument
                 duration:(float)duration;
{
    if (duration > maxDuration) maxDuration = duration;
    [scoreLines appendFormat:@"i \"%@\" 0 %0.2f\n", [instrument uniqueName], duration];
}

- (void)setProperty:(OCSProperty *)property 
            toValue:(float)value; 
{
    [properties addObject:property];
    [values addObject:[NSNumber numberWithFloat:value]];
}

- (void)play;
{
    [[OCSManager sharedOCSManager] playEvent:self];
}

- (void)setProperties;
{
    for (int i=0; i<[properties count]; i++) {
        OCSProperty *prop = [properties objectAtIndex:i];
        float val = [[values objectAtIndex:i] floatValue];
        [prop setValue:val];
        NSLog(@"Setting %@ to %g", prop, val);
    }
}


- (NSString *)stringForCSD;
{
    return [NSString stringWithFormat:@"%@",scoreLines];
}

@end
