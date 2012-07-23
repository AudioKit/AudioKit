//
//  OCSProperty.m
//  Objective-Csound
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
@synthesize value = currentValue;
@synthesize audio;
@synthesize control;
@synthesize constant;
@synthesize output;

- (id)init
{
    self = [super init];
    if (self) {
        // ARB / AOP - need to investigate why this can't be a-rate
        audio    = [OCSParameter parameterWithString:@"Property"];
        control  = [OCSControl   parameterWithString:@"Property"];
        constant = [OCSConstant  parameterWithString:@"Property"];
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

- (void)setAudio:(OCSParameter *)p {
    audio = p;
    output = audio;
}

- (void)setControl:(OCSControl *)p {
    control = p;
    output = control;
}
- (void)setConstant:(OCSConstant *)p {
    constant = p;
    output = constant;
}

- (NSString *)description {
    return [output parameterString];
}

@end
