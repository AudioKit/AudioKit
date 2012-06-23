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
                 Pitch:(OCSParam *)pch
          GrainDensity:(OCSParam *)dens
       AmplitudeOffset:(OCSParamControl *)ampOffset
           PitchOffset:(OCSParamControl *)pchOffset
         GrainDuration:(OCSParamControl *)gdur
      MaxGrainDuration:(OCSParamConstant *)maxgdur
         GrainFunction:(OCSFunctionTable *)gFunction
        WindowFunction:(OCSFunctionTable *)wFunction;
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
                 Pitch:(OCSParam *)pch
          GrainDensity:(OCSParam *)dens
       AmplitudeOffset:(OCSParamControl *)ampOffset
           PitchOffset:(OCSParamControl *)pchOffset
         GrainDuration:(OCSParamControl *)gdur
      MaxGrainDuration:(OCSParamConstant *)maxgdur
         GrainFunction:(OCSFunctionTable *)gFunction
        WindowFunction:(OCSFunctionTable *)wFunction
IsRandomGrainFunctionIndex:(BOOL)isRandGrainIndex;
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
