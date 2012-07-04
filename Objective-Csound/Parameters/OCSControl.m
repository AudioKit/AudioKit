//
//  OCSControl.m
//  Objective-Csound
//
//  Created by Aurelius Prochazka on 6/9/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSControl.h"

@implementation OCSControl

/// Initializes to default values
- (id)init
{
    self = [super init];
    type = @"gk";
    return self;
}

- (id)initWithString:(NSString *)aString
{
    self = [super init];
    if (self) {
        type = @"gk";
        parameterString = [NSString stringWithFormat:@"%@%@%i", type, aString, _myID];
    }
    return self;
}

- (id)toCPS;
{
    OCSControl * new = [[OCSControl alloc] init];
    [new setParameterString:[NSString stringWithFormat:@"cpspch(%@)", parameterString]];
    return new;
}


@end
