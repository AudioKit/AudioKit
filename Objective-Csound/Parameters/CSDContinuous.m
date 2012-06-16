//
//  CSDContinuous.m
//  ExampleProject
//
//  Created by Adam Boulanger on 6/15/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//
//

#import "CSDContinuous.h"
#import "CSDParamControl.h"

@implementation CSDContinuous
@synthesize maximumValue;
@synthesize minimumValue;
@synthesize initValue;
@synthesize value;
@synthesize uniqueIdentifier;
@synthesize output;

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

-(id)init:(float)aInitValue Max:(float)maxValue Min:(float)minValue Tag:(int)aTag isControlRate:(BOOL)control 
{
    self = [super init];
    
    maximumValue = maxValue;
    minimumValue = minValue;
    initValue = aInitValue;
    value = aInitValue;
    
    if (self) {
        if(isControl)
        {
            output = [CSDParamControl paramWithString:[self uniqueName]];
        } else {
            output = [CSDParam paramWithString:[self uniqueName]];
        }
    }
    return self;
}

-(NSString *)convertToCsd
{
    return [NSString stringWithFormat:@"%@ chnget %@", output, uniqueIdentifier];
}
                      
-(NSString *) uniqueName
{
    return [NSString stringWithFormat:@"%@%p", [self class], self];
}


@end
