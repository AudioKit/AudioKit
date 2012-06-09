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
    type = @"a";
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

+(id)paramWithString:(NSString *)aString
{
    return [[self alloc] initWithString:aString];
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
//Deprecated
//+(id)paramWithOpcode:(CSDOpcode *)someOpcode
//{
//    return [[self alloc] initWithOpcode:[someOpcode output]];
//}


@end
