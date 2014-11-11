//
//  AKControl.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 6/9/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "AKControl.h"

@implementation AKControl


- (instancetype)initWithString:(NSString *)aString
{
    self = [super init];
    if (self) {
        self.parameterString = [NSString stringWithFormat:@"k%@%i", aString, _myID];
    }
    return self;
}

- (instancetype)initGlobalWithString:(NSString *)aString
{
    self = [super init];
    if (self) {
        self.parameterString = [NSString stringWithFormat:@"gk%@%i", aString, _myID];
    }
    return self;
}

- (instancetype)initWithMinimum:(float)minimum
                        maximum:(float)maximum;
{
    return [self initWithValue:minimum
                       minimum:minimum
                       maximum:maximum];
}

- (instancetype)initWithValue:(float)initialValue
                      minimum:(float)minimum
                      maximum:(float)maximum;
{
    self = [self init];
    if (self) {
        self.value        = initialValue;
        self.initialValue = initialValue;
        self.minimum = minimum;
        self.maximum = maximum;
    }
    return self;
}

- (void)reset {
    self.value = self.initialValue;
}

- (void)randomize;
{
    float width = self.maximum - self.minimum;
    [self setValue:(((float) rand() / RAND_MAX) * width) + self.minimum];
}

- (instancetype)toCPS;
{
    AKControl *new = [[AKControl alloc] init];
    [new setParameterString:[NSString stringWithFormat:@"cpspch(%@)", self.parameterString]];
    return new;
}

@end
