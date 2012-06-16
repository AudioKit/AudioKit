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
-(void)playNote:(NSDictionary *)noteEvent {
    NSString * noteEventString = @"";
    for (int i=0; i<noteEvent.count; i++) {
        noteEventString = [noteEventString stringByAppendingFormat:@" %@", [noteEvent objectForKey:[NSNumber numberWithInt:i]]];
    }
    [[CSDManager sharedCSDManager] playNote:noteEventString OnInstrument:self];
}



@end
