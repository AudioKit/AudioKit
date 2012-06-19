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

-(id)init:(float)aInitValue Max:(float)maxValue Min:(float)minValue
{
    self = [super init];
    if (self) {
        maximumValue = maxValue;
        minimumValue = minValue;
        initValue = aInitValue;
        value = aInitValue;
        
        uniqueIdentifier = [NSString stringWithFormat:@"cont%@%p", [self class], self];

        output = [CSDParam paramWithFormat:@"a%@", [self uniqueName]];
        
    }
    return self;
}

-(id)init:(float)aInitValue Max:(float)maxValue Min:(float)minValue isControlRate:(BOOL)control 
{
    self = [super init];
    
    maximumValue = maxValue;
    minimumValue = minValue;
    initValue = aInitValue;
    value = aInitValue;
    isControl = control;
    
    uniqueIdentifier = [NSString stringWithFormat:@"cont%@%p", [self class], self];
    
    //Csound manual gives chnget output as a,k,i-rate but csound-iOS doc refers to k-rate only
    if (self) {
        if(isControl)
        {
            output = [CSDParam paramWithFormat:@"k%@", [self uniqueName]];
        } else {
            output = [CSDParam paramWithFormat:@"a%@", [self uniqueName]];
            
        }
    }

    return self;
}

-(NSString *)convertToCsd
{
    return [NSString stringWithFormat:@"%@ chnget \"%@\"\n", output, uniqueIdentifier];
}
                      
-(NSString *) uniqueName
{
    return [NSString stringWithFormat:@"%@%p", [self class], self];
}

#pragma mark BaseValueCacheable
-(void)setup:(CsoundObj*)csoundObj {
    channelPtr = [csoundObj getInputChannelPtr:[self uniqueIdentifier]];
    *channelPtr = [self value];
}

-(void)updateValuesToCsound {
    *channelPtr = [self value];  
}

@end
