//
//  OCSParameter+Operation.m
//  Objective-C Sound
//
//  Created by Aurelius Prochazka on 10/9/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSParameter+Operation.h"

@implementation OCSParameter (Operation)

- (NSString *)operationName {
    NSString *basename = [NSString stringWithFormat:@"%@", [self class]];
    basename = [basename stringByReplacingOccurrencesOfString:@"OCS" withString:@""];
    return basename;
}

- (NSString *)stringForCSD {
    //Override in subclass
    return @"Undefined";
}

- (NSString *)udoFile {
    //Override in subclass
    return @"Undefined";
}

@end
