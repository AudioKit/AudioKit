//
//  OCSParamControl.m
//
//  Created by Aurelius Prochazka on 6/9/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSParamControl.h"

@implementation OCSParamControl

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

@end
