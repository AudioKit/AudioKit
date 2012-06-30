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
    
    OCSParam *audio;
    OCSParamControl *control;
    OCSParamConstant *constant;
    OCSParam *output;
    
    //channelName
    float* channelPtr;
}
@end

@implementation OCSProperty
@synthesize maximumValue;
@synthesize minimumValue;
@synthesize initValue;
@synthesize value;
@synthesize audio;
@synthesize control;
@synthesize constant;
@synthesize output;

/// Initializes to default values
- (id)init
{
    self = [super init];
    if (self) {
        // ARB / AOP - need to investigate why this can't be a-rate
        audio    = [OCSParam paramWithString:@"Property"];
        control  = [OCSParamControl paramWithString:@"Property"];
        constant = [OCSParamConstant paramWithString:@"Property"];
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

- (id)initWithValue:(float)initialValue 
           minValue:(float)minValue 
           maxValue:(float)maxValue;{
    self = [self init];
    initValue = initialValue;
    value = initialValue;
    minimumValue = minValue;
    maximumValue = maxValue;
    return self;
}

- (void)setAudio:(OCSParam *)p {
    audio = p;
    output = audio;
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
    return [NSString stringWithFormat:@"%@ chnget \"PropertyFor%@\"\n",  output, output];
}

- (NSString *)stringForCSDSetValue {
    return [NSString stringWithFormat:@"chnset %@, \"PropertyFor%@\"\n", output, output];
}

#pragma mark BaseValueCacheable

- (void)setup:(CsoundObj*)csoundObj {
    channelPtr = [csoundObj getInputChannelPtr:[NSString stringWithFormat:@"PropertyFor%@",[output parameterString]]];
    *channelPtr = [self value];
}

- (void)updateValuesToCsound {
    *channelPtr = [self value];  
}
- (void)updateValuesFromCsound {
    [self setValue:*channelPtr];
}

/// Gives the CSD string for the output parameter.  
- (NSString *)description {
    return [output parameterString];
}

@end
