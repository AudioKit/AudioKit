//
//  OCSOutputStereo.m
//
//  Created by Aurelius Prochazka on 6/9/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSOutputStereo.h"

@implementation OCSOutputStereo

-(NSString *) convertToCsd {
    return [NSString stringWithFormat:@"outs %@, %@\n",inputLeft, inputRight];
}

-(id) initWithMonoInput:(OCSParam *) in
{
    return [self initWithInputLeft:in InputRight:in];
}

-(id) initWithInputLeft:(OCSParam *) inLeft
             InputRight:(OCSParam *) inRight
{
    self = [super init];
    if (self) {
        inputLeft  = inLeft;
        inputRight = inRight;
    }
    return self; 
}

@end
