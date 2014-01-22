//
//  AKTrackedPitchSchouten.m
//  AudioKit
//
//  Created by Adam Boulanger on 9/18/13.
//  Copyright (c) 2013 Hear For Yourself. All rights reserved.
//

#import "AKTrackedFrequencySchouten.h"

@interface AKTrackedFrequencySchouten ()
{
    AKFSignal *asig;
    AKControl *iampThresh;
}
@end

@implementation AKTrackedFrequencySchouten

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
    return [NSString stringWithFormat:@"%@, kUnused pvspitch %@, %@", self, asig, iampThresh];
}

@end