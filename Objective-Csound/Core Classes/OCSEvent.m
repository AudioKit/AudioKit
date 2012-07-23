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
    NSMutableArray *notePropertyValues;
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
@synthesize notePropertyValues;
@synthesize properties;

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
        notePropertyValues = [[NSMutableArray alloc] init];
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
        notePropertyValues = [[NSMutableArray alloc] initWithArray:[instr noteProperties]];
        for (int i = 0; i < [propertyValues count]; i++) {
            
            OCSProperty *prop = [[instr noteProperties] objectAtIndex:i];
            NSNumber *val = [NSNumber numberWithFloat:[prop value]];
            [notePropertyValues replaceObjectAtIndex:i withObject:val];
        }
        eventNumber  = [instrument instrumentNumber] + _myID/100000.0;
        scoreLine = [NSMutableString stringWithFormat:@"i %0.5f 0 10000", eventNumber];
    }
    return self;
}

- (id)initWithEvent:(OCSEvent *)event 
{
    self = [self init];
    if (self) {
        instr = [event instrument];
        notePropertyValues = [NSMutableArray arrayWithArray:[event notePropertyValues]];
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

- (id)initWithInstrumentProperty:(OCSInstrumentProperty *)property
                           value:(float)value;
{
    self = [self init];
    if (self) {
        [self setInstrumentProperty:property toValue:value];
    }
    return self;
}

- (void)setNoteProperty:(OCSNoteProperty *)property 
                 toValue:(float)value; 
{
    int index = [[instr noteProperties] indexOfObject:property];
    [notePropertyValues replaceObjectAtIndex:index withObject:[NSNumber numberWithFloat:value]];
    //    [properties addObject:property];
    //    [propertyValues addObject:[NSNumber numberWithFloat:value]];
}

- (void)setInstrumentProperty:(OCSInstrumentProperty *)property 
            toValue:(float)value; 
{
    [properties addObject:property];
    [propertyValues addObject:[NSNumber numberWithFloat:value]];
}

- (void)trigger;
{
    [[OCSManager sharedOCSManager] triggerEvent:self];
}

- (void)setNoteProperties;
{
    for (NSNumber *value in notePropertyValues) {
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
