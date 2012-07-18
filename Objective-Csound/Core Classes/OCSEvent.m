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
    NSMutableString *scoreLine;
    NSMutableArray *noteParameterValues;
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
@synthesize noteParameterValues;
@synthesize properties;

static int currentID = 1;

- (id)init {
    self = [super init];
    if (self) {
        _myID = currentID++;
        scoreLine  = [[NSMutableString alloc] init];
        noteParameterValues = [[NSMutableArray alloc] init];
        properties = [[NSMutableArray alloc] init];
        propertyValues = [[NSMutableArray alloc] init];
    }
    return self;
}

- (id)initWithInstrument:(OCSInstrument *)instrument;
{
    self = [self init];
    if (self) {
        instr = instrument;
        noteParameterValues = [[NSMutableArray alloc] initWithArray:[instr noteParameters]];
        for (int i = 0; i < [propertyValues count]; i++) {
            
            OCSProperty *prop = [[instr noteParameters] objectAtIndex:i];
            NSNumber *val = [NSNumber numberWithFloat:[prop value]];
            [noteParameterValues replaceObjectAtIndex:i withObject:val];
        }
        eventNumber  = [instrument instrumentNumber] + _myID/100000.0;
        scoreLine = [NSMutableString stringWithFormat:@"i %0.5f 0 -1", eventNumber];
    }
    return self;
}

- (id)initWithEvent:(OCSEvent *)event 
{
    self = [self init];
    if (self) {
        instr = [event instrument];
        noteParameterValues = [NSMutableArray arrayWithArray:[event noteParameterValues]];
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

- (void)setNoteParameter:(OCSProperty *)property 
                 toValue:(float)value; 
{
    int index = [[instr noteParameters] indexOfObject:property];
    [noteParameterValues replaceObjectAtIndex:index withObject:[NSNumber numberWithFloat:value]];
    //    [properties addObject:property];
    //    [propertyValues addObject:[NSNumber numberWithFloat:value]];
}

- (void)setProperty:(OCSProperty *)property 
            toValue:(float)value; 
{
    [properties addObject:property];
    [propertyValues addObject:[NSNumber numberWithFloat:value]];
}

- (void)trigger;
{
    [[OCSManager sharedOCSManager] triggerEvent:self];
}

- (void)setNoteParameters;
{
    for (NSNumber *value in noteParameterValues) {
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


- (NSString *)stringForCSD;
{
    NSLog(@"%@\n", scoreLine);
    return [NSString stringWithFormat:@"%@",scoreLine];
}

@end
