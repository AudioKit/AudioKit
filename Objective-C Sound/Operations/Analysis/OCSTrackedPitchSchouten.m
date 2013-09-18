//
//  OCSTrackedPitchSchouten.m
//  SocialMedia Sounds
//
//  Created by Adam Boulanger on 9/18/13.
//  Copyright (c) 2013 Adam Boulanger. All rights reserved.
//

#import "OCSTrackedPitchSchouten.h"

@interface OCSTrackedPitchSchouten ()
{
    OCSFSignal *asig;
    OCSControl *iampThresh;
}
@end

@implementation OCSTrackedPitchSchouten

-(id)initWithFSignalSource:(OCSFSignal *)fSignalSource
  amplitudeThreshold:(OCSControl *)amplitude
{
    self = [super initWithString:[self operationName]];
    if (self) {
        asig = fSignalSource;
        iampThresh = amplitude;
    }
    return self;
}

-(NSString *)stringForCSD
{
    return [NSString stringWithFormat:@"%@, kUnused pvspitch %@, %@", self, asig, iampThresh];
}

@end
