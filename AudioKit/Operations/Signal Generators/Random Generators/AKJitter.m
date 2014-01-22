//
//  AKJitter.m
//  AudioKit
//
//  Auto-generated from scripts by Aurelius Prochazka on 10/21/13.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//
//  Implementation of Csound's jitter:
//  http://www.csounds.com/manual/html/jitter.html
//

#import "AKJitter.h"

@interface AKJitter () {
    AKControl *kamp;
    AKControl *kcpsMax;
    AKControl *kcpsMin;
}
@end

@implementation AKJitter

- (instancetype)initWithAmplitude:(AKControl *)amplitude
                     minFrequency:(AKControl *)minFrequency
                     maxFrequency:(AKControl *)maxFrequency
{
    self = [super initWithString:[self operationName]];
    if (self) {
        kamp = amplitude;
        kcpsMax = maxFrequency;
        kcpsMin = minFrequency;
    }
    return self;
}

- (NSString *)stringForCSD {
    return [NSString stringWithFormat:
            @"%@ jitter %@, %@, %@",
            self, kamp, kcpsMin, kcpsMax];
}

@end