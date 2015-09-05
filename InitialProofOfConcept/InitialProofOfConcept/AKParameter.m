//
//  AKParameter.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 9/3/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKParameter.h"

@implementation AKParameter {
    float actualValue;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        actualValue = 0;
    }
    return self;
}

- (void)create {
    NSLog(@"Warning, 'create' should be overwritten in the subclasses");
}

- (Float32)compute {
    NSLog(@"Warning, 'compute' should be overwritten in the subclasses");
    return 0.0;
}

- (void)destroy {
    NSLog(@"Warning, 'destroy' should be overwritten in the subclasses");
}

- (instancetype)initAsConstant:(float)value
{
    if ([self init]) {
        actualValue = value;
    }
    return self;
}


- (void)bind:(float *)binding
{
    _value = binding;
    *_value = actualValue;
}

@end
