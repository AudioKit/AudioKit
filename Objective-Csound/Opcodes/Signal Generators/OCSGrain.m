//
//  OCSGrain.m
//  ExampleProject
//
//  Created by Adam Boulanger on 6/21/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSGrain.h"

@interface OCSGrain () {
    OCSParam *amp;
    OCSParam *frequency;
    OCSParam *density;
    OCSParamControl *ampOffset;
    OCSParamControl *pchOffset;
    OCSParamControl *duration;
    OCSParamConstant *maxDuration;
    OCSFTable *gFunction;
    OCSFTable *wFunction;
    BOOL isRandomGrainFunctionIndex;
    OCSParam *output;
}
@end

@implementation OCSGrain

@synthesize output;

- (id)initWithGrainFunction:(OCSFTable *)grainFunction
             windowFunction:(OCSFTable *)windowFunction
           maxGrainDuration:(OCSParamConstant *)maxGrainDuration
                  amplitude:(OCSParam *)amplitude
             grainFrequency:(OCSParam *)grainFrequency
               grainDensity:(OCSParam *)grainDensity  
              grainDuration:(OCSParamControl *)grainDuration
      maxAmplitudeDeviation:(OCSParamControl *)maxAmplitudeDeviation
          maxPitchDeviation:(OCSParamControl *)maxPitchDeviation;
{
    self = [super init];
    if (self) {
        output      = [OCSParam paramWithString:[self opcodeName]];
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

/// CSD Represenation: 
/// ares grain xamp, xpitch, xdens, kampoff, kpitchoff, kgdur, igfn, iwfn, imgdur [, igrnd]
- (NSString *)stringForCSD
{
    
    int randomnessFlag = isRandomGrainFunctionIndex ? 0 : 1;
    return [NSString stringWithFormat:
            @"%@ grain %@, %@, %@, %@, %@, %@, %@, %@, %@, %d",
            output, amp, frequency, density, ampOffset, pchOffset, duration,
            gFunction, wFunction, maxDuration, randomnessFlag];
}

/// Gives the CSD string for the output parameter.  
- (NSString *)description {
    return [output parameterString];
}

@end
