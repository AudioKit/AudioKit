//
//  CSDOrchestra.m
//  ExampleProject
//
//  Created by Aurelius Prochazka on 5/30/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "CSDOrchestra.h"

@implementation CSDOrchestra

@synthesize instruments;

-(id) init {
    self = [super init];
    if (self) {
        instruments = [[NSMutableArray alloc] init];
    }
    return self; 
}

-(int) addInstrument:(CSDInstrument *) instrument {
    [instruments addObject:instrument];
    return [instruments indexOfObject:instrument]+ 1;
}

@end
