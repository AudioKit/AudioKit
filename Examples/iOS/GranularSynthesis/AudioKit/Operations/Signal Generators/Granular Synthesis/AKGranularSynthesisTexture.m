//
//  AKGranularSynthesisTexture.m
//  AudioKit
//
//  Auto-generated from scripts by Aurelius Prochazka on 8/3/14.
//  Copyright (c) 2014 Hear For Yourself. All rights reserved.
//
//  Implementation of Csound's grain:
//  http://www.csounds.com/manual/html/grain.html
//

#import "AKGranularSynthesisTexture.h"

@implementation AKGranularSynthesisTexture
{
    AKConstant *igfn;
    AKConstant *iwfn;
    AKConstant *imgdur;
    AKControl *kgdur;
    AKControl *kpitchoff;
    AKParameter *xpitch;
    AKControl *kampoff;
    AKParameter *xamp;
    AKParameter *xdens;
    BOOL useRandomGrainOffset;
}

- (instancetype)initWithGrainFTable:(AKConstant *)grainFTable
                       windowFTable:(AKConstant *)windowFTable
               maximumGrainDuration:(AKConstant *)maximumGrainDuration
               averageGrainDuration:(AKControl *)averageGrainDuration
          maximumFrequencyDeviation:(AKControl *)maximumFrequencyDeviation
                     grainFrequency:(AKParameter *)grainFrequency
          maximumAmplitudeDeviation:(AKControl *)maximumAmplitudeDeviation
                     grainAmplitude:(AKParameter *)grainAmplitude
                       grainDensity:(AKParameter *)grainDensity
{
    self = [super initWithString:[self operationName]];
    if (self) {
        igfn = grainFTable;
        iwfn = windowFTable;
        imgdur = maximumGrainDuration;
        kgdur = averageGrainDuration;
        kpitchoff = maximumFrequencyDeviation;
        xpitch = grainFrequency;
        kampoff = maximumAmplitudeDeviation;
        xamp = grainAmplitude;
        xdens = grainDensity;
        useRandomGrainOffset = YES;
    }
    return self;
}

- (void)setOptionalUseRandomGrainOffset:(BOOL)useRandomOffset {
    useRandomGrainOffset = useRandomOffset;
}

- (NSString *)stringForCSD {
    int igrnd = useRandomGrainOffset ? 1 : 0;
    return [NSString stringWithFormat:
            @"%@ grain %@, %@, %@, %@, %@, %@, %@, %@, %@, %d",
            self, xamp, xpitch, xdens, kampoff, kpitchoff, kgdur, igfn, iwfn, imgdur, igrnd];
}

@end