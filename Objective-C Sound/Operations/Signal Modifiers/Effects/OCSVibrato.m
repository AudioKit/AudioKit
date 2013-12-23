//
//  OCSVibrato.m
//  Objective-C Sound
//
//  Auto-generated from database on 11/4/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//
//  Implementation of Csound's vibrato:
//  http://www.csounds.com/manual/html/vibrato.html
//

#import "OCSVibrato.h"

@interface OCSVibrato () {
    OCSFTable *ifn;
    OCSControl *kAverageFreq;
    OCSControl *kRandAmountFreq;
    OCSControl *kcpsMinRate;
    OCSControl *kcpsMaxRate;
    OCSControl *kAverageAmp;
    OCSControl *kRandAmountAmp;
    OCSControl *kAmpMinRate;
    OCSControl *kAmpMaxRate;
    OCSConstant *iphs;
}
@end

@implementation OCSVibrato

- (instancetype)initWithVibratoShapeTable:(OCSFTable *)vibratoShapeTable
                         averageFrequency:(OCSControl *)averageFrequency
                      frequencyRandomness:(OCSControl *)frequencyRandomness
               minimumFrequencyRandomness:(OCSControl *)minimumFrequencyRandomness
               maximumFrequencyRandomness:(OCSControl *)maximumFrequencyRandomness
                         averageAmplitude:(OCSControl *)averageAmplitude
                       amplitudeDeviation:(OCSControl *)amplitudeDeviation
               minimumAmplitudeRandomness:(OCSControl *)minimumAmplitudeRandomness
               maximumAmplitudeRandomness:(OCSControl *)maximumAmplitudeRandomness
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
        iphs = ocsp(0);
    }
    return self;
}

- (void)setOptionalPhase:(OCSConstant *)phase {
	iphs = phase;
}

- (NSString *)stringForCSD {
    return [NSString stringWithFormat:
            @"%@ vibrato %@, %@, %@, %@, %@, %@, %@, %@, %@, %@",
            self, kAverageAmp, kAverageFreq, kRandAmountAmp, kRandAmountFreq, kAmpMinRate, kAmpMaxRate, kcpsMinRate, kcpsMaxRate, ifn, iphs];
}

@end