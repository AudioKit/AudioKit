//
//  AKGrain.m
//  AudioKit
//
//  Created by Adam Boulanger on 6/21/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "AKGrain.h"

@interface AKGrain () {
    AKParameter *amp;
    AKParameter *frequency;
    AKParameter *density;
    AKControl *ampOffset;
    AKControl *pchOffset;
    AKControl *duration;
    AKConstant *maxDuration;
    AKFTable *gFunction;
    AKFTable *wFunction;
    BOOL isRandomGrainFunctionIndex;
}
@end

@implementation AKGrain

- (instancetype)initWithGrainFunction:(AKFTable *)grainFunction
                       windowFunction:(AKFTable *)windowFunction
                     maxGrainDuration:(AKConstant *)maxGrainDuration
                            amplitude:(AKParameter *)amplitude
                       grainFrequency:(AKParameter *)grainFrequency
                         grainDensity:(AKParameter *)grainDensity
                        grainDuration:(AKControl *)grainDuration
                maxAmplitudeDeviation:(AKControl *)maxAmplitudeDeviation
                    maxPitchDeviation:(AKControl *)maxPitchDeviation;
{
    self = [super initWithString:[self operationName]];
    if (self) {
        amp         = amplitude;
        frequency   = grainFrequency;
        density     = grainDensity;
        ampOffset   = maxAmplitudeDeviation;
        pchOffset   = maxPitchDeviation;
        duration    = grainDuration;
        maxDuration = maxGrainDuration;
        gFunction   = grainFunction;
        wFunction   = windowFunction;
        
        isRandomGrainFunctionIndex = YES;
    }
    return self;
}

- (void) turnOffGrainOffsetRandomness {
    isRandomGrainFunctionIndex = NO;
}

// Csound prototype: ares grain xamp, xpitch, xdens, kampoff, kpitchoff, kgdur, igfn, iwfn, imgdur (, igrnd)
- (NSString *)stringForCSD
{
    
    int randomnessFlag = isRandomGrainFunctionIndex ? 0 : 1;
    return [NSString stringWithFormat:
            @"%@ grain %@, %@, %@, %@, %@, %@, %@, %@, %@, %d",
            self, amp, frequency, density, ampOffset, pchOffset, duration,
            gFunction, wFunction, maxDuration, randomnessFlag];
}

@end
