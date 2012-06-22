//
//  OCSInstrument.m
//
//  Created by Aurelius Prochazka on 4/11/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSInstrument.h"
#import "OCSOrchestra.h"

typedef enum {
    kInstrument=1,
    kStartTime=2,
    kDuration=3
} kRequiredPValues;

@implementation OCSInstrument
@synthesize orchestra;
@synthesize finalOutput;
@synthesize csdRepresentation;
@synthesize propertyList;

static int currentID = 1;

-(void) joinOrchestra:(OCSOrchestra *) newOrchestra {
    orchestra = newOrchestra;
    [newOrchestra addInstrument:self];
}

-(id) initWithOrchestra:(OCSOrchestra *) newOrchestra {
    self = [super init];
    if (self) {
        _myID = currentID++;
        [self joinOrchestra:newOrchestra];
        duration = [OCSParamConstant paramWithPValue:kDuration];
        
        propertyList = [[NSMutableArray alloc] init ];
        csdRepresentation = [NSMutableString stringWithString:@""]; 
    }
    return self; 
}
-(NSString *) uniqueName {
    return [NSString stringWithFormat:@"%@%i", [self class], _myID];
}

-(void) addOpcode:(OCSOpcode *)newOpcode {
    [csdRepresentation appendString:[newOpcode convertToCsd]];
}

-(void)addFunctionTable:(OCSFunctionTable *)newFunctionTable {
    [csdRepresentation appendString:[newFunctionTable text]];
}
-(void)playNoteForDuration:(float)dur {
    NSString * noteEventString = [NSString stringWithFormat:@"%0.2f", dur];
    [[OCSManager sharedOCSManager] playNote:noteEventString OnInstrument:self];
}

-(void)playNote:(NSDictionary *)noteEvent {
    NSString * noteEventString = @"";
    for (int i=0; i<noteEvent.count; i++) {
        noteEventString = [noteEventString stringByAppendingFormat:@" %@", [noteEvent objectForKey:[NSNumber numberWithInt:i]]];
    }
    [[OCSManager sharedOCSManager] playNote:noteEventString OnInstrument:self];
}

+(void) resetID {
    currentID = 1;
}

-(void)addProperty:(OCSProperty *)prop 
{
    [csdRepresentation appendString:[prop convertToCsd]];
    //where I want to update csound's valuesCache array
    //[[OCSManager sharedOCSManager] addProperty:prop];
    [propertyList addObject:prop];
}

-(void) resetParam:(OCSParam *)p {
    [csdRepresentation appendString:[NSString stringWithFormat:@"%@ =  0\n", p]];
}
-(void)assignOutput:(OCSParam *)out To:(OCSParam *)in {
    OCSAssignment * auxOutputAssign = [[OCSAssignment alloc] initWithInput:in];
    [auxOutputAssign setOutput:out];
    [self addOpcode:auxOutputAssign];
}



@end
