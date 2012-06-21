//
//  CSDInstrument.m
//
//  Created by Aurelius Prochazka on 4/11/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "CSDInstrument.h"
#import "CSDOrchestra.h"

@implementation CSDInstrument
@synthesize orchestra;
@synthesize finalOutput;
@synthesize csdRepresentation;
@synthesize propertyList;

static int currentID = 1;

-(void) joinOrchestra:(CSDOrchestra *) newOrchestra {
    orchestra = newOrchestra;
    [newOrchestra addInstrument:self];
}

-(id) initWithOrchestra:(CSDOrchestra *) newOrchestra {
    self = [super init];
    if (self) {
        _myID = currentID++;
        [self joinOrchestra:newOrchestra];
        duration = [[CSDParamConstant alloc] initWithPValue:3];
        
        propertyList = [[NSMutableArray alloc] init ];
        csdRepresentation = [NSMutableString stringWithString:@""]; 
    }
    return self; 
}
-(NSString *) uniqueName {
    return [NSString stringWithFormat:@"%@%i", [self class], _myID];
}

-(void) addOpcode:(CSDOpcode *)newOpcode {
    [csdRepresentation appendString:[newOpcode convertToCsd]];
}

-(void)addFunctionTable:(CSDFunctionTable *)newFunctionTable {
    [csdRepresentation appendString:[newFunctionTable text]];
}
-(void)playNoteWithDuration:(float)dur {
    NSString * noteEventString = [NSString stringWithFormat:@"%0.2f", dur];
    [[CSDManager sharedCSDManager] playNote:noteEventString OnInstrument:self];
}

-(void)playNote:(NSDictionary *)noteEvent {
    NSString * noteEventString = @"";
    for (int i=0; i<noteEvent.count; i++) {
        noteEventString = [noteEventString stringByAppendingFormat:@" %@", [noteEvent objectForKey:[NSNumber numberWithInt:i]]];
    }
    [[CSDManager sharedCSDManager] playNote:noteEventString OnInstrument:self];
}

+(void) resetID {
    currentID = 1;
}

-(void)addProperty:(CSDProperty *)prop 
{
    [csdRepresentation appendString:[prop convertToCsd]];
    //where I want to update csound's valuesCache array
    //[[CSDManager sharedCSDManager] addProperty:prop];
    [propertyList addObject:prop];
}

-(void) resetParam:(CSDParam *) p {
    [csdRepresentation appendString:[NSString stringWithFormat:@"%@ =  0\n", p]];
}
-(void)assignOutput:(CSDParam *)out To:(CSDParam *) in {
    CSDAssignment * auxOutputAssign = [[CSDAssignment alloc] initWithInput:in];
    [auxOutputAssign setOutput:out];
    [self addOpcode:auxOutputAssign];
}



@end
