//
//  AKAssignment.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 6/12/12.
//  Copyright (c) 2012 Aurelius Prochazka. All rights reserved.
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
        self.state = @"connectable";
        self.dependencies = @[lhs, rhs];
    }
    return self; 
}

- (instancetype)initWithInput:(AKParameter *)input {
    self = [super initWithString:[self operationName]];
    
    if (self) {
        lhs = self;
        rhs = input;
        self.state = @"connectable";
        self.dependencies = @[rhs];

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
