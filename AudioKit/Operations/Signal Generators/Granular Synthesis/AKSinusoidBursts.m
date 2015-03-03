//
//  AKSinusoidBursts.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 10/9/12.
//  Copyright (c) 2012 Aurelius Prochazka. All rights reserved.
//

#import "AKSinusoidBursts.h"

@implementation AKSinusoidBursts
{
    AKTable *iFnA;
    AKTable *iFnB;
    AKConstant *iOlaps;
    AKConstant *iTotDur;
    AKControl *kOct;
    AKControl *kBand;
    AKControl *kRis;
    AKControl *kDur;
    AKControl *kDec;
    AKParameter *xAmp;
    AKParameter *xFund;
    AKParameter *xForm;
}

- (instancetype)initWithSineTable:(AKTable *)sineburstSynthesisTable
                   riseShapeTable:(AKTable *)riseShapeTable
                         overlaps:(AKConstant *)numberOfOverlaps
                        totalTime:(AKConstant *)totalTime
                  octavationIndex:(AKControl *)octavationIndex
                 formantBandwidth:(AKControl *)formantBandwidth
                    burstRiseTime:(AKControl *)burstRiseTime
                    burstDuration:(AKControl *)burstDuration
                   burstDecayTime:(AKControl *)burstDecayTime
                    peakAmplitude:(AKParameter *)peakAmplitude
             fundamentalFrequency:(AKParameter *)fundamentalFrequency
                 formantFrequency:(AKParameter *)formantFrequency;
{
    self = [super initWithString:[self operationName]];
    if (self) {
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
        self.state = @"connectable";
        self.dependencies = @[iFnA, iFnB, iOlaps, iTotDur, kOct, kBand, kRis, kDur, kDec, xAmp, xFund, xForm];
    }
    return self;
}

- (NSString *)stringForCSD {
    return [NSString stringWithFormat:
            @"%@ fof %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@",
            self, xAmp, xFund, xForm, kOct, kBand, kRis, kDur, kDec, iOlaps, iFnA, iFnB, iTotDur];
}
@end
