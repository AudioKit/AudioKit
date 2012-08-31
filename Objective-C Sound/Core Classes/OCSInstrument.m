//
//  OCSInstrument.m
//  Objective-C Sound
//
//  Created by Aurelius Prochazka on 4/11/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSInstrument.h"
#import "OCSManager.h"
#import "OCSAssignment.h"

typedef enum {
    kInstrument=1,
    kStartTime=2,
    kDuration=3
} kRequiredPValues;

@interface OCSInstrument () {
    OCSOrchestra *orchestra;
    NSMutableString *innerCSDRepresentation;
    int _myID;
    NSMutableArray *properties;
    NSMutableSet *userDefinedOperations;
    NSMutableSet *fTables;
}
@end

@implementation OCSInstrument

@synthesize properties;
@synthesize eventProperties;
@synthesize userDefinedOperations;
@synthesize fTables;

// -----------------------------------------------------------------------------
#  pragma mark - Initialization
// -----------------------------------------------------------------------------

static int currentID = 1;
+ (void)resetID { currentID = 1; }

- (id)init {
    self = [super init];
    if (self) {
        _myID = currentID++;
        properties = [[NSMutableArray alloc] init];
        eventProperties = [[NSMutableArray alloc] init];
        userDefinedOperations = [[NSMutableSet alloc] init];
        fTables = [[NSMutableSet alloc] init];
        innerCSDRepresentation = [NSMutableString stringWithString:@""]; 
    }
    return self; 
}

- (int)instrumentNumber {
    return _myID;
}

- (NSString *)uniqueName {
    return [NSString stringWithFormat:@"%@%i", [self class], _myID];
}

// -----------------------------------------------------------------------------
#  pragma mark - Properties
// -----------------------------------------------------------------------------

- (void)addProperty:(OCSProperty *)newProperty 
{
    [properties addObject:newProperty];
    //where I want to update csound's valuesCache array
    //[[OCSManager sharedOCSManager] addProperty:prop];
}

- (void)addEventProperty:(OCSProperty *)newEventProperty;
{
    [eventProperties addObject:newEventProperty];
}

// -----------------------------------------------------------------------------
#  pragma mark - F Tables
// -----------------------------------------------------------------------------

- (void)addFTable:(OCSFTable *)newFTable {
    [fTables addObject:newFTable];
}

- (void)addDynamicFTable:(OCSFTable *)newFTable {
    [innerCSDRepresentation appendString:[newFTable stringForCSD]];
    [innerCSDRepresentation appendString:@"\n"];
}

// -----------------------------------------------------------------------------
#  pragma mark - Operations
// -----------------------------------------------------------------------------

- (void)connect:(OCSOperation *)newOperation {
    [innerCSDRepresentation appendString:[newOperation stringForCSD]];
    [innerCSDRepresentation appendString:@"\n"];
}

- (void)addUDO:(OCSUserDefinedOperation *)newUserDefinedOperation {
    [userDefinedOperations addObject:newUserDefinedOperation];
    [innerCSDRepresentation appendString:[newUserDefinedOperation stringForCSD]];
    [innerCSDRepresentation appendString:@"\n"];
}

- (void)addString:(NSString *)newString {
    [innerCSDRepresentation appendString:newString];
    [innerCSDRepresentation appendString:@"\n"];
}

- (void)assignOutput:(OCSParameter *)output To:(OCSParameter *)input {
    OCSAssignment *auxOutputAssign = [[OCSAssignment alloc] initWithInput:input];
    [auxOutputAssign setOutput:output];
    [self connect:auxOutputAssign];
}

- (void)resetParam:(OCSParameter *)parameterToReset {
    [innerCSDRepresentation appendString:[NSString stringWithFormat:@"%@ = 0\n", parameterToReset]];
}

// -----------------------------------------------------------------------------
#  pragma mark - Csound Implementation
// -----------------------------------------------------------------------------

- (void)joinOrchestra:(OCSOrchestra *)orchestraToJoin
{
    orchestra = orchestraToJoin;
}

- (NSString *)stringForCSD
{
    NSMutableString *text = [NSMutableString stringWithString:@""];
    
    if ([properties count] + [eventProperties count] > 0 ) {
        [text appendString:@"\n;---- Inputs: Event Parameters ----\n"];
        int i = 4;
        for (OCSEventProperty *prop in eventProperties) {
            [text appendFormat:@"%@ = p%i\n", prop, i++];
        }
        [text appendString:@"\n;---- Inputs: Instrument Properties ----\n"];        
        for (OCSInstrumentProperty *prop in properties) {
            [text appendString:[prop stringForCSDGetValue]];
        }
        [text appendString:@"\n;---- Opcodes ----\n"];  
    }

    [text appendString:innerCSDRepresentation];
    
    if ([properties count] > 0) {
        [text appendString:@"\n;---- Outputs ----\n"];
        for (OCSInstrumentProperty *prop in properties) {
            [text appendString:[prop stringForCSDSetValue]];
        }
    }
    return (NSString *)text;
}

- (void)playNoteForDuration:(float)playDuration 
{
    OCSEvent *noteOn = [[OCSEvent alloc] initWithInstrument:self];
    [noteOn trigger];
    OCSEvent *noteOff = [[OCSEvent alloc] initDeactivation:noteOn 
                                             afterDuration:playDuration];
    [noteOff trigger];
}

@end
