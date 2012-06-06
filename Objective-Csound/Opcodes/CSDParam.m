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
+(id)initWithString:(NSString *)aString
{
    return [[self alloc] initWithString:aString];
}

+(id)initWithFloat:(float)aFloat
{
    return [[self alloc] initWithFloat:aFloat];
}
+(id)initWithInt:(int)aInt
{
    return [[self alloc] initWithInt:aInt];
}
+(id)initWithOpcode:(CSDOpcode *)aOpcode
{
    return [[self alloc] initWithOpcode:aOpcode];
}
+(id)initWithPValue:(int)aPValue
{
    return [[self alloc] initWithPValue:aPValue];
}

@end
