//
//  CSDParam.m
//  ExampleProject
//
//  Created by Adam Boulanger on 6/5/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "CSDParam.h"

@implementation CSDParam
@synthesize parameterString;

-(id)init
{
    self = [super init];

    return self;
}
-(id)initWithString:(NSString *)aString
{
    self = [super init];
    if (self) {
        parameterString = [NSString stringWithFormat:@"%@", aString];
    }
    return self;
}

-(id)initWithFloat:(float)aFloat
{
    self = [super init];
    if (self) {
        parameterString = [NSString stringWithFormat:@"%f", aFloat];
    }
    return self;
}
-(id)initWithInt:(int)someInt
{
    self = [super init];
    if (self) {
        type = @"i";
        parameterString = [NSString stringWithFormat:@"%d", someInt];
    }
    return self;
}

// Deprecated
//-(id)initWithOpcode:(CSDOpcode *)aOpcode
//{
//    //
//    self = [super init];
//    if (self) {
//        self = [aOpcode output];
//    }
//    return self;
//}
-(id)initWithPValue:(int)somePValue
{
    self = [super init];
    if (self) {
        type = @"i";
        parameterString = [NSString stringWithFormat:@"p%i", somePValue];
    }
    return self;
}
+(id)paramWithString:(NSString *)aString
{
    return [[self alloc] initWithString:aString];
}

+(id)paramWithFloat:(float)aFloat
{
    return [[self alloc] initWithFloat:aFloat];
}
+(id)paramWithInt:(int)someInt
{
    return [[self alloc] initWithInt:someInt];
}
//Deprecated
//+(id)paramWithOpcode:(CSDOpcode *)someOpcode
//{
//    return [[self alloc] initWithOpcode:[someOpcode output]];
//}
+(id)paramWithPValue:(int)somePValue
{
    return [[self alloc] initWithPValue:somePValue];
}

@end
