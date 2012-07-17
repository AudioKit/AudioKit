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
    NSString *scoreLine;
    NSMutableArray *properties;
    NSMutableArray * values;
    int _myID;
    float eventNumber;
}
@end



@implementation OCSEvent
@synthesize eventNumber;

static int currentID = 1;

- (id)init {
    self = [super init];
    if (self) {
        _myID = currentID++;
        scoreLine  = @"";
        properties = [[NSMutableArray alloc] init];
        values     = [[NSMutableArray alloc] init];
    }
    return self;
}

- (id)initWithInstrument:(OCSInstrument *)instrument;
{
    self = [self init];
    if (self) {
        eventNumber  = [instrument instrumentNumber] + _myID/100000.0;
        scoreLine = [NSString stringWithFormat:@"i %0.5f 0 -1 \n", eventNumber];
    }
    return self;
}

- (id)initDeactivation:(OCSEvent *)event
         afterDuration:(float)delay;
{
    self = [self init];
    if (self) {
        scoreLine = [NSString stringWithFormat:@"i -%0.5f %f 0.1 \n", 
                     [event eventNumber], delay ];

//        scoreLine = [NSString stringWithFormat:@"i \"Deactivator\" %f 0.1 %0.3f\n", 
//                     delay, [event eventNumber]];
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

- (void)setProperty:(OCSProperty *)property 
            toValue:(float)value; 
{
    [properties addObject:property];
    [values addObject:[NSNumber numberWithFloat:value]];
}

- (void)trigger;
{
    [[OCSManager sharedOCSManager] triggerEvent:self];
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
    NSLog(@"%@", scoreLine);
    return [NSString stringWithFormat:@"%@",scoreLine];
}

@end
