//
//  OCSGrain.m
//  Objective-Csound
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
    OCSParameter *output;
}
@end

@implementation OCSGrain

@synthesize output;

- (id)initWithGrainFunction:(OCSFTable *)grainFunction
             windowFunction:(OCSFTable *)windowFunction
           maxGrainDuration:(OCSConstant *)maxGrainDuration
                  amplitude:(OCSParameter *)amplitude
             grainFrequency:(OCSParameter *)grainFrequency
               grainDensity:(OCSParameter *)grainDensity  
              grainDuration:(OCSControl *)grainDuration
      maxAmplitudeDeviation:(OCSControl *)maxAmplitudeDeviation
          maxPitchDeviation:(OCSControl *)maxPitchDeviation;
{
    self = [super init];
    if (self) {
        output      = [OCSParameter parameterWithString:[self opcodeName]];
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

- (void) turnOffGrainOffsetRandomnes {
    isRandomGrainFunctionIndex = NO;
}

// Csound prototype: ares grain xamp, xpitch, xdens, kampoff, kpitchoff, kgdur, igfn, iwfn, imgdur (, igrnd)
- (NSString *)stringForCSD
{
    
    int randomnessFlag = isRandomGrainFunctionIndex ? 0 : 1;
    return [NSString stringWithFormat:
            @"%@ grain %@, %@, %@, %@, %@, %@, %@, %@, %@, %d",
            output, amp, frequency, density, ampOffset, pchOffset, duration,
            gFunction, wFunction, maxDuration, randomnessFlag];
}

- (NSString *)description {
    return [output parameterString];
}

@end
