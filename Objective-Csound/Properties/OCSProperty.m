//
//  OCSProperty.m
//
//  Created by Adam Boulanger on 6/15/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//
//

#import "OCSProperty.h"

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
        control  = [OCSParamControl paramWithFormat:@"gk%@",  [self uniqueName]];
        constant = [OCSParamConstant paramWithFormat:@"gi%@", [self uniqueName]];
        output = control;
        
    }
    return self;
}

- (id)initWithValue:(float)aInitValue
{
    self = [self init];
    initValue = aInitValue;
    value = aInitValue;

    return self;
}

- (id)initWithValue:(float)val Min:(float)min Max:(float)max
{
    self = [self init];
    initValue = val;
    value = val;
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

- (NSString *)getChannelText {
    return [NSString stringWithFormat:@"%@ chnget \"%@\"\n",  output, output];
}

- (NSString *)setChannelText {
    return [NSString stringWithFormat:@"chnset %@, \"%@\"\n", output, output];
}

- (NSString *)uniqueName {
    NSString *basename = [NSString stringWithFormat:@"%@", [self class]];
    basename = [basename stringByReplacingOccurrencesOfString:@"OCS" withString:@""];
    return basename;
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
    //AOP Test to get values back from Csound
    [self setValue:*channelPtr];
}

- (NSString *)description {
    return [output parameterString];
}

@end
