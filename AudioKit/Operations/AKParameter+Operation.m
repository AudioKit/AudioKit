//
//  AKParameter+Operation.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 10/9/12.
//  Copyright (c) 2012 Aurelius Prochazka. All rights reserved.
//

#import "AKParameter+Operation.h"

@implementation AKParameter (Operation)

- (NSString *)operationName
{
    NSString *basename = [NSString stringWithFormat:@"%@", [self class]];
    basename = [basename stringByReplacingOccurrencesOfString:@"AK" withString:@""];
    return basename;
}

- (NSString *)inlineStringForCSD
{
    //Override in subclass
    return self.parameterString;
}

- (NSString *)stringForCSD
{
    //Override in subclass
    return @"";
}

- (NSString *)udoString
{
    //Override in subclass
    return @"";
}

@end
