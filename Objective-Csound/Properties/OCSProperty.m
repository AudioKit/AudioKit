//
//  OCSProperty.m
//
//  Created by Adam Boulanger on 6/15/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//
//

#import "OCSProperty.h"

@interface OCSProperty () {
    Float32 maximumValue;
    Float32 minimumValue;
    Float32 initValue;
    Float32 value;
    
    OCSParamControl *control;
    OCSParamConstant *constant;
    OCSParamControl *output;
    
    //channelName
    float* channelPtr;
}
@end



@implementation OCSProperty
@synthesize maximumValue;
@synthesize minimumValue;
@synthesize initValue;
@synthesize value;
@synthesize control;
@synthesize constant;
@synthesize output;


- (id)init
{
    self = [super init];
    if (self) {
        // ARB / AOP - need to investigate why this can't be a-rate
        control  = [OCSParamControl paramWithString:@"gkProperty"];
        constant = [OCSParamConstant paramWithString:@"giProperty"];
        output = control;
        
    }
    return self;
}

- (id)initWithValue:(float)initialValue
{
    self = [self init];
    initValue = initialValue;
    value = initialValue;

    return self;
}

- (id)initWithValue:(float)initialValue Min:(float)min Max:(float)max
{
    self = [self init];
    initValue = initialValue;
    value = initialValue;
    minimumValue = min;
    maximumValue = max;
    return self;
}

- (void)setControl:(OCSParamControl *)p {
    control = p;
    output = control;
}
- (void)setConstant:(OCSParamConstant *)p {
    constant = p;
    output = constant;
}

- (NSString *)stringForCSDGetValue {
    return [NSString stringWithFormat:@"%@ chnget \"%@\"\n",  output, output];
}

- (NSString *)stringForCSDSetValue {
    return [NSString stringWithFormat:@"chnset %@, \"%@\"\n", output, output];
}

#pragma mark BaseValueCacheable

- (void)setup:(CsoundObj*)csoundObj {
    channelPtr = [csoundObj getInputChannelPtr:[output parameterString]];
    *channelPtr = [self value];
}

- (void)updateValuesToCsound {
    *channelPtr = [self value];  
}
- (void)updateValuesFromCsound {
    [self setValue:*channelPtr];
}

- (NSString *)description {
    return [output parameterString];
}

@end
