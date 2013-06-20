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
}
@end

@implementation OCSInstrument

// -----------------------------------------------------------------------------
#  pragma mark - Initialization
// -----------------------------------------------------------------------------

static int currentID = 1;
+ (void)resetID { currentID = 1; }

- (id)init {
    self = [super init];
    if (self) {
        _myID = currentID++;
        _properties = [[NSMutableArray alloc] init];
        _noteProperties = [[NSMutableArray alloc] init];
        _userDefinedOperations = [[NSMutableSet alloc] init];
        _fTables = [[NSMutableSet alloc] init];
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


- (void) addProperty:(OCSInstrumentProperty *)newProperty;
{
    [_properties addObject:newProperty];
}

- (void) addProperty:(OCSInstrumentProperty *)newProperty withName:(NSString *)name;
{
    [_properties addObject:newProperty];
    [newProperty setName:name];
}


- (void)addNoteProperty:(OCSNoteProperty *)newNoteProperty;
{
    [_noteProperties addObject:newNoteProperty];
}



// -----------------------------------------------------------------------------
#  pragma mark - F Tables
// -----------------------------------------------------------------------------

- (void)addFTable:(OCSFTable *)newFTable {
    [_fTables addObject:newFTable];
}

- (void)addDynamicFTable:(OCSFTable *)newFTable {
    [innerCSDRepresentation appendString:[newFTable stringForCSD]];
    [innerCSDRepresentation appendString:@"\n"];
}

// -----------------------------------------------------------------------------
#  pragma mark - Operations
// -----------------------------------------------------------------------------

- (void)connect:(OCSParameter *)newOperation {
    [innerCSDRepresentation appendString:[newOperation stringForCSD]];
    [innerCSDRepresentation appendString:@"\n"];
}

- (void)addUDO:(OCSParameter *)newUserDefinedOperation {
    [_userDefinedOperations addObject:newUserDefinedOperation];
    [innerCSDRepresentation appendString:[newUserDefinedOperation stringForCSD]];
    [innerCSDRepresentation appendString:@"\n"];
}

- (void)addString:(NSString *)newString {
    [innerCSDRepresentation appendString:newString];
    [innerCSDRepresentation appendString:@"\n"];
}

- (void)assignOutput:(OCSParameter *)output to:(OCSParameter *)input {
    OCSAssignment *auxOutputAssign = [[OCSAssignment alloc] initWithOutput:output input:input];
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
    
    if ([_properties count] + [_noteProperties count] > 0 ) {
        [text appendString:@"\n;---- Inputs: Note Properties ----\n"];

        for (OCSNoteProperty *prop in _noteProperties) {
            [text appendFormat:@"%@ = p%i\n", prop, prop.pValue];
        }
        [text appendString:@"\n;---- Inputs: Instrument Properties ----\n"];        
        for (OCSInstrumentProperty *prop in _properties) {
            [text appendString:[prop stringForCSDGetValue]];
        }
        [text appendString:@"\n;---- Opcodes ----\n"];  
    }

    [text appendString:innerCSDRepresentation];
    
    if ([_properties count] > 0) {
        [text appendString:@"\n;---- Outputs ----\n"];
        for (OCSInstrumentProperty *prop in _properties) {
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
    OCSNote *myNote = [[OCSNote alloc] initWithInstrument:self
                                              forDuration:playDuration];
    [myNote play];
}

- (void)play
{
    OCSNote *note = [[OCSNote alloc] initWithInstrument:self];
    [note play];
}

- (void)playNote:(OCSNote *)note;
{
    note.instrument = self;
    [note play];
}


- (void)stop
{
    [[OCSManager sharedOCSManager] stopInstrument:self];
}

@end
