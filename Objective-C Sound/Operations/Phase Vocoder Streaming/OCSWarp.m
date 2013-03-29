//
//  OCSWarp.m
//  Objective-C Sound
//
//  Auto-generated from database on 3/29/13.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//
//  Implementation of Csound's pvswarp:
//  http://www.csounds.com/manual/html/pvswarp.html
//

#import "OCSWarp.h"

@interface OCSWarp () {
    OCSFSignal *fsigin;
    OCSControl *kscal;
    OCSControl *kshift;
    OCSControl *klowest;
    OCSControl *kmeth;
    OCSControl *kgain;
    OCSControl *kcoefs;
}
@end

@implementation OCSWarp

- (id)initWithSourceSignal:(OCSFSignal *)sourceSignal
              scalingRatio:(OCSControl *)scalingRatio
                     shift:(OCSControl *)shift
{
    self = [super initWithString:[self operationName]];
    if (self) {
        fsigin = sourceSignal;
        kscal = scalingRatio;
        kshift = shift;
        klowest = ocsp(0);
        kmeth = ocsp(1);
        kgain = ocsp(1);
        kcoefs = ocsp(80);
    }
    return self;
}

- (void)setOptionalLowFrequency:(OCSControl *)lowFrequency {
	klowest = lowFrequency;
}

- (void)setOptionalExtractionMethod:(OCSControl *)extractionMethod {
	kmeth = extractionMethod;
}

- (void)setOptionalGain:(OCSControl *)gain {
	kgain = gain;
}

- (void)setOptionalNumberOfCoefficients:(OCSControl *)numberOfCoefficients {
	kcoefs = numberOfCoefficients;
}

- (NSString *)stringForCSD {
    return [NSString stringWithFormat:
            @"%@ pvswarp %@, %@, %@, %@, %@, %@, %@",
            self, fsigin, kscal, kshift, klowest, kmeth, kgain, kcoefs];
}

@end