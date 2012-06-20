//
//  CSDOutputStereo.m
//
//  Created by Aurelius Prochazka on 6/9/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "CSDOutputStereo.h"

@implementation CSDOutputStereo

-(NSString *) convertToCsd {
    return [NSString stringWithFormat:@"outs %@, %@\n",inputLeft, inputRight];
}

-(id) initWithMonoInput:(CSDParam *) in
{
    return [self initWithInputLeft:in InputRight:in];
}

-(id) initWithInputLeft:(CSDParam *) inLeft
             InputRight:(CSDParam *) inRight
{
    self = [super init];
    if (self) {
        inputLeft  = inLeft;
        inputRight = inRight;
    }
    return self; 
}

@end
