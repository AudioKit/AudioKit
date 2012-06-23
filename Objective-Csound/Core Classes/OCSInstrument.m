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
@synthesize propertyList;

static int currentID = 1;

-(void) joinOrchestra:(OCSOrchestra *) newOrchestra {
    orchestra = newOrchestra;
}

-(id) init {
    self = [super init];
    if (self) {
        _myID = currentID++;
        duration = [OCSParamConstant paramWithPValue:kDuration];
        propertyList = [[NSMutableArray alloc] init ];
        innerCSDRepresentation = [NSMutableString stringWithString:@""]; 
    }
    return self; 
}

-(NSString *) csdRepresentation {
    NSMutableString * text = [NSMutableString stringWithString:@""];
    
    if ([propertyList count] > 0) {
        [text appendString:@";--- INPUTS ---\n"];
        for (OCSProperty * prop in propertyList) {
            [text appendString:[prop getChannelText]];
        }
        [text appendString:@"\n;--- INSTRUMENT DEFINITION ---\n"];  
    }

    [text appendString:innerCSDRepresentation];
    
    if ([propertyList count] > 0) {
        [text appendString:@"\n;--- OUTPUTS ---\n"];
        for (OCSProperty * prop in propertyList) {
            [text appendString:[prop setChannelText]];
        }
    }
    return (NSString *)text;
}

-(NSString *) uniqueName {
    return [NSString stringWithFormat:@"%@%i", [self class], _myID];
}

-(void) addOpcode:(OCSOpcode *)newOpcode {
    [innerCSDRepresentation appendString:[newOpcode convertToCsd]];
}
-(void) addString:(NSString *) str {
    [innerCSDRepresentation appendString:str];
}


-(void)addFunctionTable:(OCSFunctionTable *)newFunctionTable {
    [innerCSDRepresentation appendString:[newFunctionTable convertToCsd]];
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
    //where I want to update csound's valuesCache array
    //[[OCSManager sharedOCSManager] addProperty:prop];
    [propertyList addObject:prop];
}

-(void) resetParam:(OCSParam *)p {
    [innerCSDRepresentation appendString:[NSString stringWithFormat:@"%@ =  0\n", p]];
}
-(void)assignOutput:(OCSParam *)out To:(OCSParam *)in {
    OCSAssignment * auxOutputAssign = [[OCSAssignment alloc] initWithInput:in];
    [auxOutputAssign setOutput:out];
    [self addOpcode:auxOutputAssign];
}



@end
