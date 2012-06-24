//
//  OCSInstrument.m
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

@implementation OCSInstrument

@synthesize properties;

static int currentID = 1;

- (id)init {
    self = [super init];
    if (self) {
        _myID = currentID++;
        duration = [OCSParamConstant paramWithPValue:kDuration];
        properties = [[NSMutableArray alloc] init ];
        innerCSDRepresentation = [NSMutableString stringWithString:@""]; 
    }
    return self; 
}

- (NSString *)uniqueName {
    return [NSString stringWithFormat:@"%@%i", [self class], _myID];
}

- (void)addProperty:(OCSProperty *)prop 
{
    [properties addObject:prop];
    //where I want to update csound's valuesCache array
    //[[OCSManager sharedOCSManager] addProperty:prop];
}

- (void)addFunctionTable:(OCSFunctionTable *)newFunctionTable {
    [innerCSDRepresentation appendString:[newFunctionTable stringForCSD]];
}

- (void)addOpcode:(OCSOpcode *)opcode {
    [innerCSDRepresentation appendString:[opcode stringForCSD]];
}
- (void)addString:(NSString *) str {
    [innerCSDRepresentation appendString:str];
}

- (void)assignOutput:(OCSParam *)out To:(OCSParam *)in {
    OCSAssignment *auxOutputAssign = [[OCSAssignment alloc] initWithInput:in];
    [auxOutputAssign setOutput:out];
    [self addOpcode:auxOutputAssign];
}
- (void)resetParam:(OCSParam *)p {
    [innerCSDRepresentation appendString:[NSString stringWithFormat:@"%@ =  0\n", p]];
}


- (void)joinOrchestra:(OCSOrchestra *) orch {
    orchestra = orch;
}

- (NSString *)csdRepresentation {
    NSMutableString *text = [NSMutableString stringWithString:@""];
    
    if ([properties count] > 0) {
        [text appendString:@";--- INPUTS ---\n"];
        for (OCSProperty *prop in properties) {
            [text appendString:[prop getChannelText]];
        }
        [text appendString:@"\n;--- INSTRUMENT DEFINITION ---\n"];  
    }

    [text appendString:innerCSDRepresentation];
    
    if ([properties count] > 0) {
        [text appendString:@"\n;--- OUTPUTS ---\n"];
        for (OCSProperty *prop in properties) {
            [text appendString:[prop setChannelText]];
        }
    }
    return (NSString *)text;
}

- (void)playNoteForDuration:(float)dur {
    NSString *noteEventString = [NSString stringWithFormat:@"%0.2f", dur];
    [[OCSManager sharedOCSManager] playNote:noteEventString OnInstrument:self];
}
+ (void)resetID {
    currentID = 1;
}






@end
