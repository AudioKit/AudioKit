//
//  CSDOutputMono.m
//  ExampleProject
//
//  Created by Aurelius Prochazka on 6/9/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "CSDOutputMono.h"

@implementation CSDOutputMono

-(NSString *) convertToCsd {
    return [NSString stringWithFormat:
            @"out %@\n",
            [input parameterString]];
}

-(id) initWithInput:(CSDParam *) i {
    self = [super init];
    if (self) {
        input = i;
    }
    return self; 
}

@end
