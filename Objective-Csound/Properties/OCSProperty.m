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
    Float32 currentValue;
    
    OCSParam *audio;
    OCSControlParam *control;
    OCSConstantParam *constant;
    OCSParam *output;
    
    //channelName
    float* channelPtr;
}
@end

@implementation OCSProperty
@synthesize maximumValue;
@synthesize minimumValue;
@synthesize initValue;
@synthesize value = currentValue;
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
        control  = [OCSControlParam paramWithString:@"Property"];
        constant = [OCSConstantParam paramWithString:@"Property"];
        output = control;
        
    }
    return self;
}

- (id)initWithMinValue:(float)minValue 
              maxValue:(float)maxValue;
{
    self = [self init];
    minimumValue = minValue;
    maximumValue = maxValue;
    return self;
}

- (id)initWithValue:(float)initialValue 
           minValue:(float)minValue 
           maxValue:(float)maxValue;
{
    self = [self init];
    initValue = initialValue;
    currentValue = initialValue;
    minimumValue = minValue;
    maximumValue = maxValue;
    return self;
}

- (void)setAudio:(OCSParam *)p {
    audio = p;
    output = audio;
}

- (void)setControl:(OCSControlParam *)p {
    control = p;
    output = control;
}
- (void)setConstant:(OCSConstantParam *)p {
    constant = p;
    output = constant;
}

- (void)setValue:(Float32)value {
    currentValue = value;
    if (value < minimumValue) {
        currentValue = minimumValue;
        NSLog(@"Out of bonds, assigning to minimum");
    }
    if (value > maximumValue) {
        currentValue = maximumValue;
        NSLog(@"Out of bonds, assigning to maximum");
    }
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
