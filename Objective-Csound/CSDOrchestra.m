//
//  CSDOrchestra.m
//  ExampleProject
//
//  Created by Aurelius Prochazka on 5/30/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "CSDOrchestra.h"

@implementation CSDOrchestra


@synthesize functionStatements;
@synthesize instruments;

-(void) addInstrument:(CSDInstrument *) instrument {
    [instruments addObject:instrument];
}
-(void) addFunctionStatement:(CSDFunctionStatement *) f {
    [functionStatements addObject:f];
}

@end
