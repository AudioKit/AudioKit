//
//  OCSConstant.m
//  Objective-C Sound
//
//  Created by Aurelius Prochazka on 6/9/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSConstant.h"

@implementation OCSConstant

- (id)init
{
    self = [super init];
    return self;
}

- (id)initWithString:(NSString *)name
{
    self = [super init];
    if (self) {
        parameterString = [NSString stringWithFormat:@"i%@%i", name, _myID];
    }
    return self;
}

- (id)initGlobalWithString:(NSString *)name
{
    self = [super init];
    if (self) {
        parameterString = [NSString stringWithFormat:@"gi%@%i", name, _myID];
    }
    return self;
}

- (id)initWithFloat:(float)value
{
    self = [super init];
    if (self) {
        parameterString = [NSString stringWithFormat:@"%g", value];
    }
    return self;
}

- (id)initWithNumber:(NSNumber *)number
{
    self = [super init];
    if (self) {
        parameterString = [NSString stringWithFormat:@"%@", number];
    }
    return self;
}


- (id)initWithInt:(int)value
{
    self = [super init];
    if (self) {
        parameterString = [NSString stringWithFormat:@"%d", value];
    }
    return self;
}

- (id)initWithFilename:(NSString *)filename
{
    self = [super init];
    if (self) {
        parameterString = [NSString stringWithFormat:@"\"%@\"", filename];
    }
    return self;
}

+ (id)parameterWithFloat:(float)value
{
    return [[self alloc] initWithFloat:value];
}
+ (id)parameterWithNumber:(NSNumber *)number    
{
    return [[self alloc] initWithNumber:number];
}
+ (id)parameterWithInt:(int)value
{
    return [[self alloc] initWithInt:value];
}
+ (id)parameterWithFilename:(NSString *)filename
{
    return [[self alloc] initWithFilename:filename];
}

@end
