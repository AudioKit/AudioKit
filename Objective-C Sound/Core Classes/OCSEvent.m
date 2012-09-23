//
//  OCSEvent.m
//  Objective-C Sound
//
//  Created by Aurelius Prochazka on 7/1/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSEvent.h"
#import "OCSManager.h"

typedef void (^MyBlockType)();

@interface OCSEvent () {
    NSMutableString *scoreLine;
    NSMutableDictionary *noteProperties;
    NSMutableArray *eventPropertyValues;
    NSMutableArray *properties;
    NSMutableArray *propertyValues;
    MyBlockType block;
    int _myID;
    float eventNumber;
    OCSInstrument *instr;
    
    BOOL isDeactivator;
    
    BOOL isNewNote;
}
@end

@implementation OCSEvent

@synthesize eventNumber;
@synthesize instrument = instr;
@synthesize eventPropertyValues;
@synthesize properties;
@synthesize isDeactivator;

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
        noteProperties = [[NSMutableDictionary alloc] init];
        properties = [[NSMutableArray alloc] init];
        propertyValues = [[NSMutableArray alloc] init];
        
        isNewNote = NO;
        isDeactivator = NO;
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
        
        isDeactivator = NO;
    }
    return self;
}

- (id)initWithInstrument:(OCSInstrument *)instrument;
{
    return [self initWithInstrument:instrument duration:-1];
}


// -----------------------------------------------------------------------------
#  pragma mark - Note Based Events
// -----------------------------------------------------------------------------

@synthesize note;
@synthesize isNewNote;

- (id)initWithNote:(OCSNote *)newNote {
    self = [self init];
    if (self) {
        isNewNote =  YES;
        note = newNote;
        //note.instrumentnotePropertyValues = note.propertyValues;
        eventNumber  = [note.instrument instrumentNumber] + _myID/100000.0;
        scoreLine = [NSMutableString stringWithFormat:@"i %0.5f 0 -1", eventNumber];
    }
    return self;
}

- (void)setNoteProperty:(OCSNoteProperty *)noteProperty
                toValue:(float)value;
{
    noteProperty.value = value;
}

- (id)initWithNote:(OCSNote *)newNote block:(void (^)())aBlock {
    self = [self initWithNote:newNote];
    if (self) {
        block = aBlock;
    }
    return self;
}


- (id)initWithBlock:(void (^)())aBlock {
    self = [self init];
    if (self) {
        block = aBlock;
    }
    return self;
}

- (void)runBlock {
    if (self->block) block();
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
        if (event.note) {
            note = event.note;
            noteProperties = [noteProperties copy];
        }
        isDeactivator = NO;
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
        isDeactivator = YES;

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
        isDeactivator = NO;
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

- (void)setNoteProperties;
{
    NSLog(@"deprecated");
//    for (NSString* key in note.properties) {
//        OCSNoteProperty *prop = [note.properties objectForKey:key];
//        [scoreLine appendFormat:@" %f", [prop value]];
//        NSLog(@"Setting Note Property %@ to %f", key, [prop value]);
//    }
}

- (void)setInstrumentProperties;
{
    for (int i=0; i<[properties count]; i++) {
        OCSProperty *prop = [properties objectAtIndex:i];
        float val = [[propertyValues objectAtIndex:i] floatValue];
        [prop setValue:val];
        NSLog(@"Setting Instrument Property %@ to %g", prop, val);
    }
}

// -----------------------------------------------------------------------------
#  pragma mark - Csound Implementation
// -----------------------------------------------------------------------------

- (void)trigger;
{
    [[OCSManager sharedOCSManager] triggerEvent:self];
}

- (void)stop;
{
    OCSEvent *stopEvent = [[OCSEvent alloc] initDeactivation:self afterDuration:0.0];
    [[OCSManager sharedOCSManager] triggerEvent:stopEvent];
}

- (NSString *)stringForCSD;
{
    if (![scoreLine isEqual:@""]) NSLog(@"Event Scoreline: %@\n", scoreLine);
    return [NSString stringWithFormat:@"%@",scoreLine];
}

@end
