//
//  AKHighPassFilter.m
//  AudioKit
//
//  Auto-generated from scripts by Aurelius Prochazka on 11/6/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//
//  Implementation of Csound's atone:
//  http://www.csounds.com/manual/html/atone.html
//

#import "AKHighPassFilter.h"

@implementation AKHighPassFilter
{
    AKAudio *asig;
    AKControl *khp;
}

- (instancetype)initWithAudioSource:(AKAudio *)audioSource
                     halfPowerPoint:(AKControl *)halfPowerPoint
{
    self = [super initWithString:[self operationName]];
    if (self) {
        asig = audioSource;
        khp = halfPowerPoint;
    }
    return self;
}

- (NSString *)stringForCSD {
    return [NSString stringWithFormat:
            @"%@ atone %@, %@",
            self, asig, khp];
}

@end