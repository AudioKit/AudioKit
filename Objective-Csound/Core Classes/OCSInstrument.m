//
//  OCSInstrument.m
//  Objective-Csound
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
    NSMutableSet *myUDOs;
}
@end

@implementation OCSInstrument

@synthesize properties;
@synthesize userDefinedOpcodes;

static int currentID = 1;

/// Initializes to default values
- (id)init {
    self = [super init];
    if (self) {
        _myID = currentID++;
        duration = [[OCSConstant alloc] initWithPValue:kDuration];
        properties = [[NSMutableArray alloc] init];
        userDefinedOpcodes = [[NSMutableSet alloc] init];
        innerCSDRepresentation = [NSMutableString stringWithString:@""]; 
    }
    return self; 
}

- (NSString *)uniqueName {
    return [NSString stringWithFormat:@"%@%i", [self class], _myID];
}

- (void)addProperty:(OCSProperty *)newProperty 
{
    [properties addObject:newProperty];
    //where I want to update csound's valuesCache array
    //[[OCSManager sharedOCSManager] addProperty:prop];
}

- (void)addFTable:(OCSFTable *)newFTable {
    [innerCSDRepresentation appendString:[newFTable stringForCSD]];
    [innerCSDRepresentation appendString:@"\n"];
}

- (void)addOpcode:(OCSOpcode *)newOpcode {
    [innerCSDRepresentation appendString:[newOpcode stringForCSD]];
    [innerCSDRepresentation appendString:@"\n"];
}

- (void)addUDO:(OCSUserDefinedOpcode *)newUserDefinedOpcode {
    [userDefinedOpcodes addObject:newUserDefinedOpcode];
    [innerCSDRepresentation appendString:[newUserDefinedOpcode stringForCSD]];
    [innerCSDRepresentation appendString:@"\n"];
}

- (void)addString:(NSString *)newString {
    [innerCSDRepresentation appendString:newString];
    [innerCSDRepresentation appendString:@"\n"];
}

- (void)assignOutput:(OCSParameter *)output To:(OCSParameter *)input {
    OCSAssignment *auxOutputAssign = [[OCSAssignment alloc] initWithInput:input];
    [auxOutputAssign setOutput:output];
    [self addOpcode:auxOutputAssign];
}

- (void)resetParam:(OCSParameter *)parameterToReset {
    [innerCSDRepresentation appendString:[NSString stringWithFormat:@"%@ = 0\n", parameterToReset]];
}

- (void)joinOrchestra:(OCSOrchestra *)orchestraToJoin {
    orchestra = orchestraToJoin;
}

- (NSString *)stringForCSD {
    NSMutableString *text = [NSMutableString stringWithString:@""];
    
    if ([properties count] > 0) {
        [text appendString:@"\n;--- INPUTS ---\n"];
        for (OCSProperty *prop in properties) {
            [text appendString:[prop stringForCSDGetValue]];
        }
        [text appendString:@"\n;--- INSTRUMENT DEFINITION ---\n"];  
    }

    [text appendString:innerCSDRepresentation];
    
    if ([properties count] > 0) {
        [text appendString:@"\n;--- OUTPUTS ---\n"];
        for (OCSProperty *prop in properties) {
            [text appendString:[prop stringForCSDSetValue]];
        }
    }
    return (NSString *)text;
}

- (void)playNoteForDuration:(float)playDuration {
    NSString *noteEventString = [NSString stringWithFormat:@"%0.2f", playDuration];
    [[OCSManager sharedOCSManager] playNote:noteEventString OnInstrument:self];
}
+ (void)resetID {
    currentID = 1;
}






@end
