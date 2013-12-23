//
//  OCSGrain.m
//  Objective-C Sound
//
//  Created by Adam Boulanger on 6/21/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSGrain.h"

@interface OCSGrain () {
    OCSParameter *amp;
    OCSParameter *frequency;
    OCSParameter *density;
    OCSControl *ampOffset;
    OCSControl *pchOffset;
    OCSControl *duration;
    OCSConstant *maxDuration;
    OCSFTable *gFunction;
    OCSFTable *wFunction;
    BOOL isRandomGrainFunctionIndex;
}
@end

@implementation OCSGrain

- (instancetype)initWithGrainFunction:(OCSFTable *)grainFunction
                       windowFunction:(OCSFTable *)windowFunction
                     maxGrainDuration:(OCSConstant *)maxGrainDuration
                            amplitude:(OCSParameter *)amplitude
                       grainFrequency:(OCSParameter *)grainFrequency
                         grainDensity:(OCSParameter *)grainDensity
                        grainDuration:(OCSControl *)grainDuration
                maxAmplitudeDeviation:(OCSControl *)maxAmplitudeDeviation
                    maxPitchDeviation:(OCSControl *)maxPitchDeviation;
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
