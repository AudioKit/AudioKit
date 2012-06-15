//
//  CSDContinuous.m
//  ExampleProject
//
//  Created by Adam Boulanger on 6/15/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//
//

#import "CSDContinuous.h"

@implementation CSDContinuous
@synthesize maximumValue;
@synthesize minimumValue;
@synthesize initValue;
@synthesize value;
@synthesize uniqueIdentifier;

-(id)init:(float)aInitValue Max:(float)maxValue Min:(float)minValue Tag:(int)aTag
{
    self = [super init];
    if (self) {
        maximumValue = maxValue;
        minimumValue = minValue;
        initValue = aInitValue;
        value = aInitValue;
        
        uniqueIdentifier = [NSString stringWithFormat:@"cont_%d", aTag];
        
        //[[[CSDManager sharedCSDManager] myContinuousManager] addContinuousParam:
    }
    return self;
}

-(NSString *)convertToCsd
{
    return [NSString stringWithFormat:@"%@ chnget %@", , uniqueIdentifier];
}


@end
