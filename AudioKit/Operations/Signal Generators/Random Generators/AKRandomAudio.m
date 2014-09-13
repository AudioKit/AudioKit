//
//  AKRandomAudio.m
//  AudioKit
//
//  Auto-generated from scripts by Aurelius Prochazka on 12/26/13.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//
//  Implementation of Csound's random:
//  http://www.csounds.com/manual/html/random.html
//

#import "AKRandomAudio.h"

@implementation AKRandomAudio
{
    AKControl *kmin;
    AKControl *kmax;
}

- (instancetype)initWithMinimum:(AKControl *)minimum
                        maximum:(AKControl *)maximum
{
    self = [super initWithString:[self operationName]];
    if (self) {
        kmin = minimum;
        kmax = maximum;
    }
    return self;
}

- (NSString *)stringForCSD {
    return [NSString stringWithFormat:
            @"%@ random %@, %@",
            self, kmin, kmax];
}

@end