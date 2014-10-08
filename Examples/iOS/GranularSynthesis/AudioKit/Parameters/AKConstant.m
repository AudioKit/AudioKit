//
//  AKConstant.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 6/9/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "AKConstant.h"

@implementation AKConstant

- (instancetype)init
{
    self = [super init];
    return self;
}

- (instancetype)initWithString:(NSString *)name
{
    self = [super init];
    if (self) {
        self.parameterString = [NSString stringWithFormat:@"i%@%i", name, _myID];
    }
    return self;
}

- (instancetype)initGlobalWithString:(NSString *)name
{
    self = [super init];
    if (self) {
        self.parameterString = [NSString stringWithFormat:@"gi%@%i", name, _myID];
    }
    return self;
}

- (instancetype)initWithFloat:(float)value
{
    self = [super init];
    if (self) {
        self.parameterString = [NSString stringWithFormat:@"%g", value];
    }
    return self;
}

- (instancetype)initWithNumber:(NSNumber *)number
{
    self = [super init];
    if (self) {
        self.parameterString = [NSString stringWithFormat:@"%@", number];
    }
    return self;
}

- (instancetype)initWithValue:(NSNumber *)value {
    return [self initWithNumber:value];
}

- (instancetype)initWithInt:(int)value
{
    self = [super init];
    if (self) {
        self.parameterString = [NSString stringWithFormat:@"%d", value];
    }
    return self;
}

- (instancetype)initWithFilename:(NSString *)filename
{
    self = [super init];
    if (self) {
        self.parameterString = [NSString stringWithFormat:@"\"%@\"", filename];
    }
    return self;
}

+ (instancetype)constantWithFloat:(float)value {
    return [[self alloc] initWithFloat:value];
}

+ (instancetype)constantWithNumber:(NSNumber *)number {
    return [[self alloc] initWithNumber:number];
}

+ (instancetype)constantWithInt:(int)value {
    return [[self alloc] initWithInt:value];
}

+ (instancetype)constantWithFilename:(NSString *)filename {
    return [[self alloc] initWithFilename:filename];
}

+ (instancetype)constantWithControl:(AKControl *)control {
    return [self parameterWithFormat:@"i(%@)", control];
}

@end
