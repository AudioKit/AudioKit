//
//  CSDParam.m
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
    type = @"a";
    return self;
}
-(id)initWithString:(NSString *)aString
{
    self = [super init];
    if (self) {
        parameterString = [NSString stringWithFormat:@"a%@", aString];
    }
    return self;
}

-(id)initWithExpression:(NSString *)aExpression
{
    self = [super init];
    if (self) {
        parameterString = [NSString stringWithString:aExpression];
    }
    return self;
}

+(id)paramWithString:(NSString *)aString
{
    return [[self alloc] initWithString:aString];
}

+(id)paramWithExpression:(NSString *)aString
{
    return [[self alloc] initWithExpression:aString];
}

-(NSString *) description {
    return parameterString;
}

@end
