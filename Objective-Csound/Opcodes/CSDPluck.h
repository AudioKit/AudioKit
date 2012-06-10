//
//  CSDPluck.h
//
//  Created by Adam Boulanger on 6/1/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "CSDOpcode.h"
#import "CSDFunctionTable.h"

#import "CSDConstants.h"
#import "CSDParam.h"

//ARB - NOTE: started using weight in signatures for things that tend to be 0-1 and scaler/factor for >1
//ARB - NOTE: trying to deal with(hide) strange paramter that switches between different decay initializations which then 
//   recycles optional parameters for different init functions
//ARB - TODO: ival parameters don't need to be strings

@interface CSDPluck : CSDOpcode {
    CSDParam * output;
}

@property (nonatomic, strong) CSDParam * output;
//ares pluck kamp, kcps, icps, ifn, imeth [, iparm1] [, iparm2]
@property (nonatomic, strong) NSString *amplitude;
@property (nonatomic, strong) NSString *pitch;
@property (nonatomic, strong) NSString *pitchDecayBuffer;
@property (nonatomic, strong) CSDFunctionTable *functionTable;

@property (nonatomic, strong) NSString *decayMethod;
@property (nonatomic, strong) NSString *roughness;
@property (nonatomic, strong) NSString *stretchFactor;
@property (nonatomic, strong) NSString *currentSampleWeight;
@property (nonatomic, strong) NSString *previousSampleWeight;

-(id)initWithAmplitude:(NSString *) amp
                 Pitch:(NSString *) pch
    DecayedPitchBuffer:(NSString *) hz
         FunctionTable:(CSDFunctionTable *) f
        RecursiveDecay:(BOOL) orSimpleDecay;

-(id)initWithAmplitude:(NSString *) amp
                 Pitch:(NSString *) pch
    DecayedPitchBuffer:(NSString *) hz
         FunctionTable:(CSDFunctionTable *) f  
StretchedAveragingDecay:(NSString *) stretchScaler;

-(id)initWithAmplitude:(NSString *) amp
                 Pitch:(NSString *) pch
    DecayedPitchBuffer:(NSString *) hz
         FunctionTable:(CSDFunctionTable *) f
       SimpleDrumDecay:(NSString *)roughWeight;

-(id)initWithAmplitude:(NSString *) amp
                 Pitch:(NSString *) pch
    DecayedPitchBuffer:(NSString *) hz
         FunctionTable:(CSDFunctionTable *) f
    StretchedDrumDecay:(NSString *) roughWeight
         StretchFactor:(NSString *)stretchScaler;

-(id)initWithAmplitude:(NSString *) amp
                 Pitch:(NSString *) pch
    DecayedPitchBuffer:(NSString *) hz
         FunctionTable:(CSDFunctionTable *) f
  WeightedAverageDecay:(NSString *) currSampleWeight
         StretchFactor:(NSString *)prevSampleWeight;

@end
