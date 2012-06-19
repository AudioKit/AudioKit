//
//  CSDParamConstant.m
//
//  Created by Aurelius Prochazka on 6/9/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "CSDParamConstant.h"

@implementation CSDParamConstant

-(id)init
{
    self = [super init];
    type = @"gi";
    return self;
}

-(id)initWithString:(NSString *)aString
{
    self = [super init];
    if (self) {
        type = @"i";
        parameterString = [NSString stringWithFormat:@"%@%@", type, aString];
    }
    return self;
}

-(id)initWithFloat:(float)aFloat
{
    self = [super init];
    if (self) {
        type = @"gi";
        parameterString = [NSString stringWithFormat:@"%f", aFloat];
    }
    return self;
}
-(id)initWithInt:(int)someInt
{
    self = [super init];
    if (self) {
        type = @"gi";
        parameterString = [NSString stringWithFormat:@"%d", someInt];
    }
    return self;
}


-(id)initWithPValue:(int)somePValue
{
    self = [super init];
    if (self) {
        type = @"gi";
        parameterString = [NSString stringWithFormat:@"p%i", somePValue];
    }
    return self;
}


+(id)paramWithFloat:(float)aFloat
{
    return [[self alloc] initWithFloat:aFloat];
}
+(id)paramWithInt:(int)someInt
{
    return [[self alloc] initWithInt:someInt];
}
+(id)paramWithPValue:(int)somePValue
{
    return [[self alloc] initWithPValue:somePValue];
}


@end
