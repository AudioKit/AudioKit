//
//  CSDParamControl.m
//
//  Created by Aurelius Prochazka on 6/9/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "CSDParamControl.h"

@implementation CSDParamControl

-(id)init
{
    self = [super init];
    type = @"k";
    return self;
}

-(id)initWithString:(NSString *)aString
{
    self = [super init];
    if (self) {
        parameterString = [NSString stringWithFormat:@"k%@", aString];
    }
    return self;
}

@end
