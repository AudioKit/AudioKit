//
//  AKAssignment.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 6/12/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "AKAssignment.h"

@implementation AKAssignment
{
    AKParameter *lhs;
    AKParameter *rhs;
}

- (instancetype)initWithOutput:(AKParameter *)output
                         input:(AKParameter *)input {
    self = [super initWithString:[self operationName]];
    
    if (self) {
        lhs = output;
        rhs = input;
    }
    return self; 
}

- (instancetype)initWithInput:(AKParameter *)input {
    self = [super initWithString:[self operationName]];
    
    if (self) {
        lhs = [AKParameter parameterWithString:[self operationName]];
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
