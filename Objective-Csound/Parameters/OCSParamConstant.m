//
//  OCSParamConstant.m
//
//  Created by Aurelius Prochazka on 6/9/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSParamConstant.h"

@implementation OCSParamConstant

/// Initializes to default values
- (id)init
{
    self = [super init];
    type = @"gi";
    return self;
}

- (id)initWithString:(NSString *)name
{
    self = [super init];
    if (self) {
        type = @"gi";
        parameterString = [NSString stringWithFormat:@"%@%@%i", type, name, _myID];
    }
    return self;
}

- (id)initWithFloat:(float)value
{
    self = [super init];
    if (self) {
        type = @"gi";
        parameterString = [NSString stringWithFormat:@"%g", value];
    }
    return self;
}
- (id)initWithInt:(int)value
{
    self = [super init];
    if (self) {
        type = @"gi";
        parameterString = [NSString stringWithFormat:@"%d", value];
    }
    return self;
}

- (id)initWithPValue:(int)p
{
    self = [super init];
    if (self) {
        type = @"gi";
        parameterString = [NSString stringWithFormat:@"p%i", p];
    }
    return self;
}

- (id)initWithFilename:(NSString *)filename
{
    self = [super init];
    if (self) {
        type = @"gi";
        parameterString = [NSString stringWithFormat:@"\"%@\"", filename];
    }
    return self;
}

+ (id)paramWithFloat:(float)value
{
    return [[self alloc] initWithFloat:value];
}
+ (id)paramWithInt:(int)value
{
    return [[self alloc] initWithInt:value];
}
+ (id)paramWithFilename:(NSString *)filename
{
    return [[self alloc] initWithFilename:filename];
}


@end
