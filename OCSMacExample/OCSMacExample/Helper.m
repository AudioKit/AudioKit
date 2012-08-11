//
//  Helper.m
//  Objective-C Sound Example
//
//  Created by Aurelius Prochazka on 7/3/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "Helper.h"

@implementation Helper

+ (float)randomFloatFrom:(float)minimum to:(float)maximum; 
{
    float width = maximum - minimum;
    return (((float) rand() / RAND_MAX) * width) + minimum;
}




@end
