//
//  OCSSinusoidBursts.m
//  OCS iPad Examples
//
//  Created by Aurelius Prochazka on 10/9/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSSinusoidBursts.h"

@interface OCSSinusoidBursts () {
    OCSParameter *ares;
}
@end

@implementation OCSSinusoidBursts

@synthesize sineburstSynthesisTable = iFnA;
@synthesize riseShapeTable = iFnB;
@synthesize numberOfOverlaps = iOlaps;
@synthesize totalTime = iTotDur;
@synthesize octavationIndex = kOct;
@synthesize formantBandwidth = kBand;
@synthesize burstRiseTime = kRis;
@synthesize burstDuration = kDur;
@synthesize burstDecayTime = kDec;
@synthesize peakAmplitude = xAmp;
@synthesize fundamentalFrequency = xFund;
@synthesize formantFrequency = xForm;

-(id) initWithSineTable:(OCSSineTable *)sineburstSynthesisTable
         riseShapeTable:(OCSFTable *)riseShapeTable
               Overlaps:(OCSConstant *)numberOfOverlaps
              totalTime:(OCSConstant *)totalTime
        octavationIndex:(OCSControl *)octavationIndex
       formantBandwidth:(OCSControl *)formantBandwidth
          burstRiseTime:(OCSControl *)burstRiseTime
          burstDuration:(OCSControl *)burstDuration
         burstDecayTime:(OCSControl *)burstDecayTime
          peakAmplitude:(OCSParameter *)peakAmplitude
   fundamentalFrequency:(OCSParameter *)fundamentalFrequency
       formantFrequence:(OCSParameter *)formantFrequency;
{
    self = [super init];
    if (self) {
        ares = [OCSParameter parameterWithString:[self operationName]];
        iFnA = sineburstSynthesisTable;
        iFnB = riseShapeTable;
        iOlaps = numberOfOverlaps;
        iTotDur = totalTime;
        kOct = octavationIndex;
        kBand = formantBandwidth;
        kRis = burstRiseTime;
        kDur = burstDuration;
        kDec = burstDecayTime;
        xAmp = peakAmplitude;
        xFund = fundamentalFrequency;
        xForm = formantFrequency;
    }
    return self;
}

- (NSString *)stringForCSD {
    return [NSString stringWithFormat:
            @"%@ oscili %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@",
            ares, xAmp, xFund, xForm, kOct, kBand, kRis, kDur, kDec, iOlaps, iFnA, iFnB, iTotDur];
}
@end
