//
//  CSDInstrument.m
//
//  Created by Aurelius Prochazka on 4/11/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "CSDInstrument.h"
#import "CSDOrchestra.h"
//
@implementation CSDInstrument
@synthesize orchestra;
@synthesize finalOutput;
@synthesize csdRepresentation;

-(void) joinOrchestra:(CSDOrchestra *) newOrchestra {
    orchestra = newOrchestra;
    [newOrchestra addInstrument:self];
}

-(id) initWithOrchestra:(CSDOrchestra *) newOrchestra {
    self = [super init];
    if (self) {
        [self joinOrchestra:newOrchestra];
        csdRepresentation = [NSMutableString stringWithString:@""]; 
    }
    return self; 
}

-(void) addOpcode:(CSDOpcode *)newOpcode {
    [csdRepresentation appendString:[newOpcode convertToCsd]];
}

-(void)addFunctionTable:(CSDFunctionTable *)newFunctionTable {
    [csdRepresentation appendString:[newFunctionTable text]];
}
-(void)playNote:(NSDictionary *)noteEvent {
    int instrumentNumber = [[orchestra instruments] indexOfObject:self] + 1;
    NSString * noteEventString = @"";

    for (int i=0; i<noteEvent.count; i++) {
       
        noteEventString = [noteEventString stringByAppendingFormat:@" %@", [noteEvent objectForKey:[NSNumber numberWithInt:i]]];
    }
    NSLog(@"fdsa%@fdsa", noteEventString);
    [[CSDManager sharedCSDManager] playNote:noteEventString OnInstrument:instrumentNumber];
    
}



@end
