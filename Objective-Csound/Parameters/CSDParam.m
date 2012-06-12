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

+(id)paramWithFormat:(NSString *)format, ... {
    va_list argumentList;
    va_start(argumentList, format);
    return [[self alloc] initWithExpression:[[NSString alloc] initWithFormat:format arguments:argumentList]];
    va_end(argumentList);
}



-(NSString *) description {
    return parameterString;
}

@end
