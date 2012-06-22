//
//  OCSPluck.m
//
//  Created by Adam Boulanger on 6/1/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSPluck.h"

typedef enum
{
    kDecayTypeSimpleAveraging=1,
    kDecayTypeStretchedAveraging=2,
    kDecayTypeSimpleDrum=3,
    kDecayTypeStretchedDrum=4,
    kDecayTypeWeightedAveraging=5,
    kDecayTypeRecursiveFirstOrder=6
}PluckDecayTypes;

//ares pluck kamp, kcps, icps, ifn, imeth [, iparm1] [, iparm2]

@implementation OCSPluck

@synthesize output;

-(id)initWithAmplitude:(OCSParamControl *)amp
   ResamplingFrequency:(OCSParamControl *)freq
   PitchDecayFrequency:(OCSParamConstant *)pchDecayFreq
CyclicDecayFunctionTable:(OCSFunctionTable *)f
        RecursiveDecay:(BOOL)orSimpleDecay
{
    self = [super init];
    if( self ) {
        output = [OCSParam paramWithString:[self uniqueName]];
        amplitude = amp;
        resamplingFrequency = freq;
        pitchDecayFrequency = pchDecayFreq;
        cyclicDecayFunction = f;
    
        //Recursive or Simple decay
        decayMethod = [OCSParamConstant paramWithInt:orSimpleDecay ? kDecayTypeRecursiveFirstOrder : kDecayTypeSimpleAveraging];
                   
        roughness = nil;
        stretchFactor = nil;
        currentSampleWeight = nil;
        stretchFactor = nil;
    }
    return self;
}


-(id)initWithAmplitude:(OCSParamControl *)amp
       ResamplingFrequency:(OCSParamControl *)freq
       PitchDecayFrequency:(OCSParamConstant *)pchDecayFreq
  CyclicDecayFunctionTable:(OCSFunctionTable *)f  
   StretchedAveragingDecay:(OCSParamConstant *)stretchScaler
{
    self = [super init];
    if( self ) {
        output = [OCSParam paramWithString:[self uniqueName]];
        amplitude = amp;
        resamplingFrequency = freq;
        pitchDecayFrequency = pchDecayFreq;
        cyclicDecayFunction = f;
        
        decayMethod = [OCSParamConstant paramWithInt:kDecayTypeStretchedAveraging];
        stretchFactor = stretchScaler;
        
        roughness = nil;
        currentSampleWeight = nil;
        stretchFactor = nil;
    }
    return self;
}

-(id)initWithAmplitude:(OCSParamControl *)amp
   ResamplingFrequency:(OCSParamControl *)freq
   PitchDecayFrequency:(OCSParamConstant *)pchDecayFreq
CyclicDecayFunctionTable:(OCSFunctionTable *)f
       SimpleDrumDecay:(OCSParamConstant *)roughWeight;
{
    self = [super init];
    if( self ) {
        output = [OCSParam paramWithString:[self uniqueName]];
        amplitude = amp;
        resamplingFrequency = freq;
        pitchDecayFrequency = pchDecayFreq;
        cyclicDecayFunction = f;
        
        decayMethod = [OCSParamConstant paramWithInt:kDecayTypeSimpleDrum];
        roughness = roughWeight;
        
        stretchFactor = nil;
        currentSampleWeight = nil;
        stretchFactor = nil;
    }
    return self;
}

-(id)initWithAmplitude:(OCSParamControl *)amp
   ResamplingFrequency:(OCSParamControl *)freq
   PitchDecayFrequency:(OCSParamConstant *)pchDecayFreq
CyclicDecayFunctionTable:(OCSFunctionTable *)f
    StretchedDrumDecay:(OCSParamConstant *)roughWeight
         StretchFactor:(OCSParamConstant *)stretchScaler
{
    self = [super init];
    if( self ) {
        output = [OCSParam paramWithString:[self uniqueName]];
        amplitude = amp;
        resamplingFrequency = freq;
        pitchDecayFrequency = pchDecayFreq;
        cyclicDecayFunction = f;
        
        decayMethod = [OCSParamConstant paramWithInt:kDecayTypeStretchedDrum];
        roughness = roughWeight;
        stretchFactor = stretchScaler;
        
        currentSampleWeight = nil;
        stretchFactor = nil;
    }
    return self;
}

-(id)initWithAmplitude:(OCSParamControl *)amp
   ResamplingFrequency:(OCSParamControl *)freq
   PitchDecayFrequency:(OCSParamConstant *)pchDecayFreq
CyclicDecayFunctionTable:(OCSFunctionTable *)f
  WeightedAverageDecay:(OCSParamConstant *)currSampleWeight
         StretchFactor:(OCSParamConstant *)prevSampleWeight
{
    self = [super init];
    if( self ) {
        output = [OCSParam paramWithString:[self uniqueName]];
        amplitude = amp;
        resamplingFrequency = freq;
        pitchDecayFrequency = pchDecayFreq;
        cyclicDecayFunction = f;
        
        decayMethod = [OCSParamConstant paramWithInt:kDecayTypeWeightedAveraging];
        currentSampleWeight = currSampleWeight;
        stretchFactor = prevSampleWeight;
    }
    return self;
}

-(NSString *) description {
    return [output parameterString];
}

@end
