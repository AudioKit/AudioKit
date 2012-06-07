//
//  CSDInstrument.m
//  CsdReinvention
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

-(void)addFunctionStatement:(CSDFunctionTable *)newFunctionStatement
{
    [csdRepresentation appendString:[newFunctionStatement text]];
}

@end
