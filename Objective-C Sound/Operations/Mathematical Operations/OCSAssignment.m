//
//  OCSAssignment.m
//  Objective-C Sound
//
//  Created by Aurelius Prochazka on 6/12/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSAssignment.h"

@interface OCSAssignment () {
    OCSParameter *in;
    OCSParameter *out;
}
@end

@implementation OCSAssignment
@synthesize output = out;

- (id)initWithInput:(OCSParameter *)input {
    self = [super init];
    
    if (self) {
        out = [OCSParameter parameterWithString:[self operationName]];
        in = input;
    }
    return self; 
}

- (NSString *)stringForCSD
{
    return [NSString stringWithFormat:@"%@ = %@", out, in];
}

- (NSString *)description {
    return [out parameterString];
}

@end
