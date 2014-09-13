//
//  AKVibrato.m
//  AudioKit
//
//  Auto-generated from scripts by Aurelius Prochazka on 11/4/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//
//  Implementation of Csound's vibrato:
//  http://www.csounds.com/manual/html/vibrato.html
//

#import "AKVibrato.h"

@implementation AKVibrato
{
    AKFTable *ifn;
    AKControl *kAverageFreq;
    AKControl *kRandAmountFreq;
    AKControl *kcpsMinRate;
    AKControl *kcpsMaxRate;
    AKControl *kAverageAmp;
    AKControl *kRandAmountAmp;
    AKControl *kAmpMinRate;
    AKControl *kAmpMaxRate;
    AKConstant *iphs;
}

- (instancetype)initWithVibratoShapeTable:(AKFTable *)vibratoShapeTable
                         averageFrequency:(AKControl *)averageFrequency
                      frequencyRandomness:(AKControl *)frequencyRandomness
               minimumFrequencyRandomness:(AKControl *)minimumFrequencyRandomness
               maximumFrequencyRandomness:(AKControl *)maximumFrequencyRandomness
                         averageAmplitude:(AKControl *)averageAmplitude
                       amplitudeDeviation:(AKControl *)amplitudeDeviation
               minimumAmplitudeRandomness:(AKControl *)minimumAmplitudeRandomness
               maximumAmplitudeRandomness:(AKControl *)maximumAmplitudeRandomness
{
    self = [super initWithString:[self operationName]];
    if (self) {
        ifn = vibratoShapeTable;
        kAverageFreq = averageFrequency;
        kRandAmountFreq = frequencyRandomness;
        kcpsMinRate = minimumFrequencyRandomness;
        kcpsMaxRate = maximumFrequencyRandomness;
        kAverageAmp = averageAmplitude;
        kRandAmountAmp = amplitudeDeviation;
        kAmpMinRate = minimumAmplitudeRandomness;
        kAmpMaxRate = maximumAmplitudeRandomness;
        iphs = akp(0);
    }
    return self;
}

- (void)setOptionalPhase:(AKConstant *)phase {
	iphs = phase;
}

- (NSString *)stringForCSD {
    return [NSString stringWithFormat:
            @"%@ vibrato %@, %@, %@, %@, %@, %@, %@, %@, %@, %@",
            self, kAverageAmp, kAverageFreq, kRandAmountAmp, kRandAmountFreq, kAmpMinRate, kAmpMaxRate, kcpsMinRate, kcpsMaxRate, ifn, iphs];
}

@end