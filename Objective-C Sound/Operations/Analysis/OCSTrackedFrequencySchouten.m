//
//  OCSTrackedPitchSchouten.m
//  Objective-C Sound
//
//  Created by Adam Boulanger on 9/18/13.
//  Copyright (c) 2013 Hear For Yourself. All rights reserved.
//

#import "OCSTrackedFrequencySchouten.h"

@interface OCSTrackedFrequencySchouten ()
{
    OCSFSignal *asig;
    OCSControl *iampThresh;
}
@end

@implementation OCSTrackedFrequencySchouten

- (instancetype)initWithFSignalSource:(OCSFSignal *)fSignalSource
                   amplitudeThreshold:(OCSControl *)amplitudeThreshold
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