//
//  CSDPluck.m
//
//  Created by Adam Boulanger on 6/1/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "CSDPluck.h"

typedef enum
{
    kDecayTypeSimpleAveraging=1,
    kDecayTypeStretchedAveraging=2,
    kDecayTypeSimpleDrum=3,
    kDecayTypeStretchedDrum=4,
    kDecayTypeWeightedAveraging=5,
    kDecayTypeRecursiveFirstOrder=6
}PluckDecayTypes;

@implementation CSDPluck

@synthesize output;
@synthesize amplitude;
@synthesize resamplingFrequency;
@synthesize pitchDecayFrequency;
@synthesize cyclicDecayFunction;
@synthesize decayMethod;
@synthesize roughness;
@synthesize stretchFactor;
@synthesize currentSampleWeight;
@synthesize previousSampleWeight;

-(id)initWithAmplitude:(CSDParamControl *)amp
   ResamplingFrequency:(CSDParamControl *)freq
   PitchDecayFrequency:(CSDParamConstant *)pchDecayFreq
CyclicDecayFunctionTable:(CSDFunctionTable *)f
        RecursiveDecay:(BOOL)orSimpleDecay
{
    self = [super init];
    if( self ) {
        output = [CSDParam paramWithString:[self uniqueName]];
        amplitude = amp;
        resamplingFrequency = freq;
        pitchDecayFrequency = pchDecayFreq;
        cyclicDecayFunction = f;
    
        //Recursive or Simple decay
        decayMethod = [CSDParamConstant paramWithInt:orSimpleDecay ? kDecayTypeRecursiveFirstOrder : kDecayTypeSimpleAveraging];
                   
        roughness = nil;
        stretchFactor = nil;
        currentSampleWeight = nil;
        stretchFactor = nil;
    }
    return self;
}


-(id)initWithAmplitude:(CSDParamControl *)amp
       ResamplingFrequency:(CSDParamControl *)freq
       PitchDecayFrequency:(CSDParamConstant *)pchDecayFreq
  CyclicDecayFunctionTable:(CSDFunctionTable *)f  
   StretchedAveragingDecay:(CSDParamConstant *)stretchScaler
{
    self = [super init];
    if( self ) {
        output = [CSDParam paramWithString:[self uniqueName]];
        amplitude = amp;
        resamplingFrequency = freq;
        pitchDecayFrequency = pchDecayFreq;
        cyclicDecayFunction = f;
        
        decayMethod = [CSDParamConstant paramWithInt:kDecayTypeStretchedAveraging];
        stretchFactor = stretchScaler;
        
        roughness = nil;
        currentSampleWeight = nil;
        stretchFactor = nil;
    }
    return self;
}

-(id)initWithAmplitude:(CSDParamControl *)amp
   ResamplingFrequency:(CSDParamControl *)freq
   PitchDecayFrequency:(CSDParamConstant *)pchDecayFreq
CyclicDecayFunctionTable:(CSDFunctionTable *)f
       SimpleDrumDecay:(CSDParamConstant *)roughWeight;
{
    self = [super init];
    if( self ) {
        output = [CSDParam paramWithString:[self uniqueName]];
        amplitude = amp;
        resamplingFrequency = freq;
        pitchDecayFrequency = pchDecayFreq;
        cyclicDecayFunction = f;
        
        decayMethod = [CSDParamConstant paramWithInt:kDecayTypeSimpleDrum];
        roughness = roughWeight;
        
        stretchFactor = nil;
        currentSampleWeight = nil;
        stretchFactor = nil;
    }
    return self;
}

-(id)initWithAmplitude:(CSDParamControl *)amp
   ResamplingFrequency:(CSDParamControl *)freq
   PitchDecayFrequency:(CSDParamConstant *)pchDecayFreq
CyclicDecayFunctionTable:(CSDFunctionTable *)f
    StretchedDrumDecay:(CSDParamConstant *)roughWeight
         StretchFactor:(CSDParamConstant *)stretchScaler
{
    self = [super init];
    if( self ) {
        output = [CSDParam paramWithString:[self uniqueName]];
        amplitude = amp;
        resamplingFrequency = freq;
        pitchDecayFrequency = pchDecayFreq;
        cyclicDecayFunction = f;
        
        decayMethod = [CSDParamConstant paramWithInt:kDecayTypeStretchedDrum];
        roughness = roughWeight;
        stretchFactor = stretchScaler;
        
        currentSampleWeight = nil;
        stretchFactor = nil;
    }
    return self;
}

-(id)initWithAmplitude:(CSDParamControl *)amp
   ResamplingFrequency:(CSDParamControl *)freq
   PitchDecayFrequency:(CSDParamConstant *)pchDecayFreq
CyclicDecayFunctionTable:(CSDFunctionTable *)f
  WeightedAverageDecay:(CSDParamConstant *)currSampleWeight
         StretchFactor:(CSDParamConstant *)prevSampleWeight
{
    self = [super init];
    if( self ) {
        output = [CSDParam paramWithString:[self uniqueName]];
        amplitude = amp;
        resamplingFrequency = freq;
        pitchDecayFrequency = pchDecayFreq;
        cyclicDecayFunction = f;
        
        decayMethod = [CSDParamConstant paramWithInt:kDecayTypeWeightedAveraging];
        currentSampleWeight = currSampleWeight;
        stretchFactor = prevSampleWeight;
    }
    return self;
}

-(NSString *) description {
    return [output parameterString];
}

@end
