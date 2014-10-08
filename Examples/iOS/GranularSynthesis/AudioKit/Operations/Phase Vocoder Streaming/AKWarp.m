//
//  AKWarp.m
//  AudioKit
//
//  Auto-generated from scripts by Aurelius Prochazka on 3/29/13.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//
//  Implementation of Csound's pvswarp:
//  http://www.csounds.com/manual/html/pvswarp.html
//

#import "AKWarp.h"

@implementation AKWarp
{
    AKFSignal *fsigin;
    AKControl *kscal;
    AKControl *kshift;
    AKControl *klowest;
    AKControl *kmeth;
    AKControl *kgain;
    AKControl *kcoefs;
}

- (instancetype)initWithSourceSignal:(AKFSignal *)sourceSignal
                        scalingRatio:(AKControl *)scalingRatio
                               shift:(AKControl *)shift
{
    self = [super initWithString:[self operationName]];
    if (self) {
        fsigin = sourceSignal;
        kscal = scalingRatio;
        kshift = shift;
        klowest = akp(0);
        kmeth = akp(1);
        kgain = akp(1);
        kcoefs = akp(80);
    }
    return self;
}

- (void)setOptionalLowFrequency:(AKControl *)lowFrequency {
	klowest = lowFrequency;
}

- (void)setOptionalExtractionMethod:(AKControl *)extractionMethod {
	kmeth = extractionMethod;
}

- (void)setOptionalGain:(AKControl *)gain {
	kgain = gain;
}

- (void)setOptionalNumberOfCoefficients:(AKControl *)numberOfCoefficients {
	kcoefs = numberOfCoefficients;
}

- (NSString *)stringForCSD {
    return [NSString stringWithFormat:
            @"%@ pvswarp %@, %@, %@, %@, %@, %@, %@",
            self, fsigin, kscal, kshift, klowest, kmeth, kgain, kcoefs];
}

@end