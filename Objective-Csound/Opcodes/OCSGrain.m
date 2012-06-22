//
//  OCSGrain.m
//  ExampleProject
//
//  Created by Adam Boulanger on 6/21/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSGrain.h"

@implementation OCSGrain

@synthesize output;

-(id)initWithAmplitude:(OCSParam *)amp
                 pitch:(OCSParam *)pch
          grainDensity:(OCSParam *)dens
       amplitudeOffset:(OCSParamControl *)ampOffset
           pitchOffset:(OCSParamControl *)pchOffset
         grainDuration:(OCSParamControl *)gdur
      maxGrainDuration:(OCSParamConstant *)maxgdur
         grainFunction:(OCSFunctionTable *)gFunction
        windowFunction:(OCSFunctionTable *)wFunction
{
    self = [super init];
    if (self) {
        output              = [OCSParam paramWithString:[self uniqueName]];
        amplitude           = amp;
        pitch               = pch;
        grainDensity        = dens;
        amplitudeOffset     = ampOffset;
        pitchOffset         = pchOffset;
        grainDuration       = gdur;
        maxGrainDuration    = maxgdur;
        grainFunction       = gFunction;
        windowFunction      = wFunction;
        
        isRandomGrainFunctionIndex = NO;
    }
    return self;
}

-(id)initWithAmplitude:(OCSParam *)amp
                 pitch:(OCSParam *)pch
          grainDensity:(OCSParam *)dens
       amplitudeOffset:(OCSParamControl *)ampOffset
           pitchOffset:(OCSParamControl *)pchOffset
         grainDuration:(OCSParamControl *)gdur
      maxGrainDuration:(OCSParamConstant *)maxgdur
         grainFunction:(OCSFunctionTable *)gFunction
        windowFunction:(OCSFunctionTable *)wFunction
isRandomGrainFunctionIndex:(BOOL)isRandGrainIndex
{
    self = [super init];
    if (self) {
        output              = [OCSParam paramWithString:[self uniqueName]];
        amplitude           = amp;
        pitch               = pch;
        grainDensity        = dens;
        amplitudeOffset     = ampOffset;
        pitchOffset         = pchOffset;
        grainDuration       = gdur;
        maxGrainDuration    = maxgdur;
        grainFunction       = gFunction;
        windowFunction      = wFunction;
        isRandomGrainFunctionIndex    = isRandGrainIndex;
    }
    return self;
}

-(NSString *)convertToCsd
{
    //ares grain xamp, xpitch, xdens, kampoff, kpitchoff, kgdur, igfn, iwfn, imgdur [, igrnd]
    int imgdur = isRandomGrainFunctionIndex ? 1 : 0;
    return [NSString stringWithFormat:
            @"%@ grain %@, %@, %@, %@, %@, %@, %@, %@, %@, %d\n",
            output, amplitude, pitch, grainDensity, amplitudeOffset, pitchOffset, grainDuration,
            grainFunction, windowFunction, maxGrainDuration, imgdur];
}

-(NSString *) description {
    return [output parameterString];
}

@end
