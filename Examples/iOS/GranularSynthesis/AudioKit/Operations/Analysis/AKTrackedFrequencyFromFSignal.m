//
//  AKTrackedFrequencyFromFSignal.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 8/3/14.
//  Copyright (c) 2014 h4y. All rights reserved.
//

#import "AKTrackedFrequencyFromFSignal.h"

@implementation AKTrackedFrequencyFromFSignal
{
    AKFSignal *asig;
    AKControl *iampThresh;
}

- (instancetype)initWithFSignalSource:(AKFSignal *)fSignalSource
                   amplitudeThreshold:(AKControl *)amplitudeThreshold
{
    self = [super initWithString:[self operationName]];
    if (self) {
        asig = fSignalSource;
        iampThresh = amplitudeThreshold;
    }
    return self;
}

- (NSString *)stringForCSD
{
    return [NSString stringWithFormat:
            @"%@, kUnused pvspitch %@, %@",
            self, asig, iampThresh];
}

@end