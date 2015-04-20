//
//  AKFSignal.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 7/22/12.
//  Copyright (c) 2012 Aurelius Prochazka. All rights reserved.
//

#import "AKFSignal.h"

@implementation AKFSignal

- (instancetype)initWithString:(NSString *)aString;
{
    self = [super init];
    if (self) {
        self.parameterString = [NSString stringWithFormat:@"f%@%@", aString, @(self.parameterID)];
    }
    return self;
}

@end
