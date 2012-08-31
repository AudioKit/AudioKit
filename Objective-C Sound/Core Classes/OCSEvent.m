//
//  OCSEvent.m
//  Objective-C Sound
//
//  Created by Aurelius Prochazka on 7/1/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSEvent.h"
#import "OCSManager.h"

@interface OCSEvent () {
    NSMutableString *scoreLine;
    NSMutableArray *eventPropertyValues;
    NSMutableArray *properties;
    NSMutableArray *propertyValues;
    int _myID;
    float eventNumber;
    OCSInstrument *instr;
}
@end

@implementation OCSEvent

@synthesize eventNumber;
@synthesize instrument = instr;
@synthesize eventPropertyValues;
@synthesize properties;

// -----------------------------------------------------------------------------
#  pragma mark - Initialization
// -----------------------------------------------------------------------------

static int currentID = 1;
+ (void)resetID { currentID = 1; }

- (id)init {
    self = [super init];
    if (self) {
        if (currentID > 99000) {
            [OCSEvent resetID];
        }
        _myID = currentID++;
        scoreLine  = [[NSMutableString alloc] init];
        eventPropertyValues = [[NSMutableArray alloc] init];
        properties = [[NSMutableArray alloc] init];
        propertyValues = [[NSMutableArray alloc] init];
    }
    return self;
}

// -----------------------------------------------------------------------------
#  pragma mark - Instrument Based Events
// -----------------------------------------------------------------------------

- (id)initWithInstrument:(OCSInstrument *)instrument duration:(float)duration;
{
    self = [self init];
    if (self) {
        instr = instrument;
        eventPropertyValues = [[NSMutableArray alloc] initWithArray:[instr eventProperties]];
        for (int i = 0; i < [propertyValues count]; i++) {
            
            OCSProperty *prop = [[instr eventProperties] objectAtIndex:i];
            NSNumber *val = [NSNumber numberWithFloat:[prop value]];
            [eventPropertyValues replaceObjectAtIndex:i withObject:val];
        }
        eventNumber  = [instrument instrumentNumber] + _myID/100000.0;
        scoreLine = [NSMutableString stringWithFormat:@"i %0.5f 0 %g", eventNumber, duration];
    }
    return self;
}

- (id)initWithInstrument:(OCSInstrument *)instrument;
{
    return [self initWithInstrument:instrument duration:-1];
}

// -----------------------------------------------------------------------------
#  pragma mark - Event Based Events
// -----------------------------------------------------------------------------

- (id)initWithEvent:(OCSEvent *)event 
{
    self = [self init];
    if (self) {
        instr = [event instrument];
        eventPropertyValues = [NSMutableArray arrayWithArray:[event eventPropertyValues]];
        eventNumber  = [event eventNumber];
        scoreLine = [NSMutableString stringWithFormat:@"i %0.5f 0 0.1", eventNumber];
    }
    return self;
}


- (id)initDeactivation:(OCSEvent *)event
         afterDuration:(float)delay;
{
    self = [self init];
    if (self) {
        scoreLine = [NSMutableString stringWithFormat:@"i -%0.5f %f 0.1", 
                     [event eventNumber], delay ];

        // This next method uses the turnoff2 opcode which might prove advantageous 
        // so I won't delete it just yet.
//        scoreLine = [NSString stringWithFormat:@"i \"Deactivator\" %f 0.1 %0.3f\n", 
//                     delay, [event eventNumber]];
    }
    return self;
}

// -----------------------------------------------------------------------------
#  pragma mark - Property Based Events
// -----------------------------------------------------------------------------

- (id)initWithInstrumentProperty:(OCSInstrumentProperty *)property
                           value:(float)value;
{
    self = [self init];
    if (self) {
        [self setInstrumentProperty:property toValue:value];
    }
    return self;
}

- (void)setEventProperty:(OCSEventProperty *)property 
                 toValue:(float)value; 
{
    NSUInteger index = [[instr eventProperties] indexOfObject:property];
    [eventPropertyValues replaceObjectAtIndex:index withObject:[NSNumber numberWithFloat:value]];
}

- (void)setInstrumentProperty:(OCSInstrumentProperty *)property 
            toValue:(float)value; 
{
    [properties addObject:property];
    [propertyValues addObject:[NSNumber numberWithFloat:value]];
}

- (void)setEventProperties;
{
    for (NSNumber *value in eventPropertyValues) {
        [scoreLine appendFormat:@" %@", value];
    }
}

- (void)setInstrumentProperties;
{
    for (int i=0; i<[properties count]; i++) {
        OCSProperty *prop = [properties objectAtIndex:i];
        float val = [[propertyValues objectAtIndex:i] floatValue];
        [prop setValue:val];
        NSLog(@"Setting %@ to %g", prop, val);
    }
}

// -----------------------------------------------------------------------------
#  pragma mark - Csound Implementation
// -----------------------------------------------------------------------------

- (void)trigger;
{
    [[OCSManager sharedOCSManager] triggerEvent:self];
}

- (NSString *)stringForCSD;
{
    NSLog(@"%@\n", scoreLine);
    return [NSString stringWithFormat:@"%@",scoreLine];
}

@end
