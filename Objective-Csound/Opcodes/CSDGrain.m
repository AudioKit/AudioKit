//
//  CSDGrain.m
//  ExampleProject
//
//  Created by Adam Boulanger on 6/21/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "CSDGrain.h"

@implementation CSDGrain
@synthesize output;
@synthesize amplitude;
@synthesize pitch;
@synthesize grainDensity;
@synthesize amplitudeOffset;
@synthesize pitchOffset;
@synthesize grainDuration;
@synthesize maxGrainDuration;
@synthesize grainFunction;
@synthesize windowFunction;
@synthesize isRandomGrainFunctionIndex;

-(id)initWithAmplitude:(CSDParam *)amp
                 pitch:(CSDParam *)pch
          grainDensity:(CSDParam *)dens
       amplitudeOffset:(CSDParamControl *)ampOffset
           pitchOffset:(CSDParamControl *)pchOffset
         grainDuration:(CSDParamControl *)gdur
      maxGrainDuration:(CSDParamConstant *)maxgdur
         grainFunction:(CSDFunctionTable *)gFunction
        windowFunction:(CSDFunctionTable *)wFunction
{
    self = [super init];
    if (self) {
        output              = [CSDParam paramWithString:[self uniqueName]];
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

-(id)initWithAmplitude:(CSDParam *)amp
pitch:(CSDParam *)pch
grainDensity:(CSDParam *)dens
amplitudeOffset:(CSDParamControl *)ampOffset
pitchOffset:(CSDParamControl *)pchOffset
grainDuration:(CSDParamControl *)gdur
maxGrainDuration:(CSDParamConstant *)maxgdur
grainFunction:(CSDFunctionTable *)gFunction
windowFunction:(CSDFunctionTable *)wFunction
isRandomGrainFunctionIndex:(BOOL)isRandGrainIndex
{
    self = [super init];
    if (self) {
        output              = [CSDParam paramWithString:[self uniqueName]];
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
