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
        NSLog(@"CSD being initialized:\n%@", csdRepresentation );
    }
    return self; 
}

-(void) addOpcode:(CSDOpcode *)newOpcode {
    /*
    [csdRepresentation appendString:[newOpcode description]];
    NSLog(@"[newOpcode description]: %@", [newOpcode description]);
    [csdRepresentation appendString:@"\n"];
     */
    [csdRepresentation appendString:[newOpcode convertToCsd]];
    NSLog(@"CSD Representation is now:\n%@", csdRepresentation);
}

-(void)addFunctionStatement:(CSDFunctionStatement *)newFunctionStatement
{
    [csdRepresentation appendString:[newFunctionStatement text]];
    NSLog(@"CSD Representation is now:\n%@", csdRepresentation );
}

@end
