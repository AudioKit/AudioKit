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
-(id)initWithInt:(int)aInt
{
    self = [super init];
    if (self) {
        parameterString = [NSString stringWithFormat:@"%d", aInt];
    }
    return self;
}

-(id)initWithOpcode:(CSDOpcode *)aOpcode
{
    //
    self = [super init];
    if (self) {
        //TODO: handle output assignment both here and maybe on opcode as well
    }
    return self;
}
-(id)initWithPValue:(int)aPValue
{
    self = [super init];
    if (self) {
        parameterString = [NSString stringWithFormat:@"p%i", aPValue];
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
+(id)paramWithInt:(int)aInt
{
    return [[self alloc] initWithInt:aInt];
}
+(id)paramWithOpcode:(CSDOpcode *)aOpcode
{
    return [[self alloc] initWithOpcode:aOpcode];
}
+(id)paramWithPValue:(int)aPValue
{
    return [[self alloc] initWithPValue:aPValue];
}

@end
