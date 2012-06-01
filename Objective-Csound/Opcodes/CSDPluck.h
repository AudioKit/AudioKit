//
//  CSDPluck.h
//  ExampleProject
//
//  Created by Adam Boulanger on 6/1/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "CSDOpcode.h"
#import "CSDFunctionStatement.h"

#import "CSDConstants.h"

//ARB - NOTE: started using weight in signatures for things that tend to be 0-1 and scaler/factor for >1
//ARB - NOTE: trying to deal with(hide) strange paramter that switches between different decay initializations which then 
//   recycles optional parameters for different init functions
//ARB - TODO: ival parameters don't need to be strings

@interface CSDPluck : CSDOpcode
//ares pluck kamp, kcps, icps, ifn, imeth [, iparm1] [, iparm2]
@property (nonatomic, strong) NSString *output;
@property (nonatomic, strong) NSString *opcode;
@property (nonatomic, strong) NSString *amplitude;
@property (nonatomic, strong) NSString *pitch;
@property (nonatomic, strong) NSString *pitchDecayBuffer;
@property (nonatomic, strong) CSDFunctionStatement *functionTable;

@property (nonatomic, strong) NSString *decayMethod;
@property (nonatomic, strong) NSString *roughness;
@property (nonatomic, strong) NSString *stretchFactor;
@property (nonatomic, strong) NSString *currentSampleWeight;
@property (nonatomic, strong) NSString *previousSampleWeight;

-(NSString *) textWithPValue:(int)p;

-(id)initWithOutput:(NSString *)out
Amplitude:(NSString *)amp
Pitch:(NSString *) pch
DecayedPitchBuffer:(NSString *) hz
FunctionTable:(CSDFunctionStatement *) f
AndRecursiveDecay:(BOOL) orSimpleDecay;

-(id)initWithOutput:(NSString *)out
Amplitude:(NSString *)amp
Pitch:(NSString *) pch
DecayedPitchBuffer:(NSString *) hz
FunctionTable:(CSDFunctionStatement *) f
AndStretchedAveragingDecay:( NSString *) stretchScaler;

-(id)initWithOutput:(NSString *)out
Amplitude:(NSString *)amp
Pitch:(NSString *) pch
DecayedPitchBuffer:(NSString *) hz
FunctionTable:(CSDFunctionStatement *) f
AndSimpleDrumDecay:( NSString *)roughWeight;

-(id)initWithOutput:(NSString *)out
Amplitude:(NSString *)amp
Pitch:(NSString *) pch
DecayedPitchBuffer:(NSString *) hz
FunctionTable:(CSDFunctionStatement *) f
AndStretchedDrumDecay:( NSString *) roughWeight
StretchFactor:( NSString *)stretchScaler;

-(id)initWithOutput:(NSString *)out
Amplitude:(NSString *)amp
Pitch:(NSString *) pch
DecayedPitchBuffer:(NSString *) hz
FunctionTable:(CSDFunctionStatement *) f
AndWeightedAverageDecay:( NSString *) currSampleWeight
StretchFactor:( NSString *)prevSampleWeight;

@end
