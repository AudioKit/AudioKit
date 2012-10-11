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
@synthesize name;

- (id)init
{
    self = [super init];
    if (self) {
        [self setName:@"Property"];
    }
    return self;
}

- (id)initWithValue:(float)initialValue 
           minValue:(float)minValue 
           maxValue:(float)maxValue;
{
    self = [self init];
    if (self) {
        initValue = initialValue;
        currentValue = initialValue;
        minimumValue = minValue;
        maximumValue = maxValue;
    }
    return self;
}

- (void)setName:(NSString *)newName {
    output  = [OCSControl   parameterWithString:newName];
    constant = [OCSConstant parameterWithString:newName];
}


- (id)initWithMinValue:(float)minValue
              maxValue:(float)maxValue;
{
    return [self initWithValue:minValue minValue:minValue maxValue:maxValue];
}

- (void)randomize;
{
    float width = maximumValue - minimumValue;
    [self setValue:(((float) rand() / RAND_MAX) * width) + minimumValue];
}


- (void)setConstant:(OCSConstant *)p {
    constant = p;
    output = constant;
}

- (NSString *)description {
    return [output parameterString];
}

@end
