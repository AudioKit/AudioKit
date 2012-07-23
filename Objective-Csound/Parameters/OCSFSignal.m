//
//  OCSFSignal.m
//  Objective-Csound
//
//  Created by Aurelius Prochazka on 7/22/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSFSignal.h"

@implementation OCSFSignal

- (id)initWithString:(NSString *)aString;
{
    self = [super init];
    if (self) {
        parameterString = [NSString stringWithFormat:@"f%@%i", aString, _myID];
    }
    return self;
}

@end
