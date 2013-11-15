//
//  OCSAssignment.m
//  Objective-C Sound
//
//  Created by Aurelius Prochazka on 6/12/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSAssignment.h"

@interface OCSAssignment () {
    OCSParameter *lhs;
    OCSParameter *rhs;
}
@end

@implementation OCSAssignment

- (instancetype)initWithOutput:(OCSParameter *)output input:(OCSParameter *)input {
    self = [super init];
    
    if (self) {
        lhs = output;
        rhs = input;
    }
    return self; 
}

- (instancetype)initWithInput:(OCSParameter *)input {
    self = [super init];
    
    if (self) {
        lhs = [OCSParameter parameterWithString:[self operationName]];
        rhs = input;
    }
    return self;
}

- (NSString *)stringForCSD
{
    return [NSString stringWithFormat:@"%@ = %@", lhs, rhs];
}

- (NSString *)description {
    return [lhs parameterString];
}

@end
