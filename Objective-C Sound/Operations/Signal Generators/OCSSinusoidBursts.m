//
//  OCSSinusoidBursts.m
//  OCS iPad Examples
//
//  Created by Aurelius Prochazka on 10/9/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSSinusoidBursts.h"

@interface OCSSinusoidBursts () {
    OCSParameter *aRes;
    OCSSineTable *iFnA;
    OCSFTable *iFnB;
    OCSConstant *iOlaps;
    OCSConstant *iTotDur;
    OCSControl *kOct;
    OCSControl *kBand;
    OCSControl *kRis;
    OCSControl *kDur;
    OCSControl *kDec;
    OCSParameter *xAmp;
    OCSParameter *xFund;
    OCSParameter *xForm;
}
@end

@implementation OCSSinusoidBursts

-(id) initWithSineTable:(OCSSineTable *)sineburstSynthesisTable
         riseShapeTable:(OCSFTable *)riseShapeTable
               overlaps:(OCSConstant *)numberOfOverlaps
              totalTime:(OCSConstant *)totalTime
        octavationIndex:(OCSControl *)octavationIndex
       formantBandwidth:(OCSControl *)formantBandwidth
          burstRiseTime:(OCSControl *)burstRiseTime
          burstDuration:(OCSControl *)burstDuration
         burstDecayTime:(OCSControl *)burstDecayTime
          peakAmplitude:(OCSParameter *)peakAmplitude
   fundamentalFrequency:(OCSParameter *)fundamentalFrequency
       formantFrequency:(OCSParameter *)formantFrequency;
{
    self = [super init];
    if (self) {
        aRes = [OCSParameter parameterWithString:[self operationName]];
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
            @"%@ fof %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@",
            aRes, xAmp, xFund, xForm, kOct, kBand, kRis, kDur, kDec, iOlaps, iFnA, iFnB, iTotDur];
}

- (NSString *)description
{
    return [aRes parameterString];
}
@end
