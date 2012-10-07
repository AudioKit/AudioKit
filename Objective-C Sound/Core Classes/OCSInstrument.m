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
@synthesize noteProperties;
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
        noteProperties = [[NSMutableArray alloc] init];
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

- (void)addNoteProperty:(OCSNoteProperty *)newNoteProperty;
{
    [noteProperties addObject:newNoteProperty];
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
    
    if ([properties count] + [noteProperties count] > 0 ) {
        [text appendString:@"\n;---- Inputs: Note Properties ----\n"];
        int i = 4;
        for (OCSNoteProperty *prop in noteProperties) {
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

- (NSString *)stopStringForCSD
{
    return [NSString stringWithFormat:@"i \"DeactivateInstrument\" 0 0.1 %i\n", _myID ];
}


- (void)playForDuration:(float)playDuration 
{
    OCSSequence *onOffSequence = [[OCSSequence alloc] init];
    OCSNote *myNote = [[OCSNote alloc] initWithInstrument:self];
    OCSEvent *myNoteOn = [[OCSEvent alloc] initWithNote:myNote];
    OCSEvent *myNoteOff = [[OCSEvent alloc] initWithBlock:^{
        [myNote stop];
    }];
    [onOffSequence addEvent:myNoteOn];
    [onOffSequence addEvent:myNoteOff afterDuration:playDuration];
    [onOffSequence play];
}

- (void)play
{
    OCSNote *note = [[OCSNote alloc] initWithInstrument:self];
    [note play];
}

- (void)stop
{
    [[OCSManager sharedOCSManager] stopInstrument:self];
}

@end
