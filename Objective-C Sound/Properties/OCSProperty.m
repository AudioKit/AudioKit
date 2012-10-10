//
//  OCSProperty.m
//  Objective-C Sound
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
@synthesize constant;

- (id)init
{
    self = [super init];
    if (self) {
        // ARB / AOP - need to investigate why this can't be a-rate
        output  = [OCSControl   parameterWithString:@"Property"];
        constant = [OCSConstant  parameterWithString:@"Property"];
    }
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


- (id)initWithMinValue:(float)minValue
              maxValue:(float)maxValue;
{
    return [self initWithValue:minValue minValue:minValue maxValue:maxValue];
}

- (void)setConstant:(OCSConstant *)p {
    constant = p;
    output = constant;
}

- (NSString *)description {
    return [output parameterString];
}

@end
