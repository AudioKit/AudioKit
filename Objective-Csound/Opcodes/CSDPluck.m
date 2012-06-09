//
//  CSDPluck.m
//
//  Created by Adam Boulanger on 6/1/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "CSDPluck.h"

@implementation CSDPluck

@synthesize output;
@synthesize amplitude;
@synthesize pitch;
@synthesize pitchDecayBuffer;
@synthesize functionTable;

@synthesize decayMethod;
@synthesize roughness;
@synthesize stretchFactor;
@synthesize currentSampleWeight;
@synthesize previousSampleWeight;

-(NSString *) textWithPValue:(int)p
{

    if ( @"p" == amplitude ) { 
        amplitude = [NSString stringWithFormat:@"p%i", p++];
    }
    if ( @"p" == pitch ) { 
        pitch = [NSString stringWithFormat:@"p%i", p++]; 
    }
    if ( @"p" == pitchDecayBuffer ) { 
        pitchDecayBuffer = [NSString stringWithFormat:@"p%i", p++];
    }
    
    NSString *decayParameters;
    switch ( [decayMethod intValue]) {
        case kDecayTypeSimpleAveraging:
            decayParameters = [NSString stringWithFormat:@"%@, %@, %@", 
                 kDecayTypeSimpleAveraging, 0, 0];
            break;
        case kDecayTypeStretchedAveraging:
            decayParameters = [NSString stringWithFormat:@"%@, %@, %@", 
                 kDecayTypeStretchedAveraging, stretchFactor, 0];
            break;
        case kDecayTypeSimpleDrum:
            decayParameters = [NSString stringWithFormat:@"%@, %@, %@", 
                 kDecayTypeSimpleDrum, roughness, 0];
            break;
        case kDecayTypeStretchedDrum:
            decayParameters = [NSString stringWithFormat:@"%@, %@, %@", 
                 kDecayTypeStretchedDrum, roughness, stretchFactor];            
            break;
        case kDecayTypeWeightedAveraging:
            decayParameters = [NSString stringWithFormat:@"%@, %@, %@", 
                 kDecayTypeWeightedAveraging, currentSampleWeight, previousSampleWeight];            
            break;
        case kDecayTypeRecursiveFirstOrder:
            decayParameters = [NSString stringWithFormat:@"%@, %@, %@", 
                 kDecayTypeRecursiveFirstOrder, 0, 0];
            break;
        default:
            NSLog(@"Invalid decayType [:textWithPValue]");
            break;
    }
    
    //ares pluck kamp, kcps, icps, ifn, imeth [, iparm1] [, iparm2]
    return [NSString stringWithFormat:@"%@ %@ %@,  %@,  %i, %@\n",
            [output parameterString], opcode, amplitude, pitch, pitchDecayBuffer, [functionTable integerIdentifier], decayParameters ];
}

-(id)initWithAmplitude:(NSString *) amp
                 Pitch:(NSString *) pch
    DecayedPitchBuffer:(NSString *) hz
         FunctionTable:(CSDFunctionTable *) f
        RecursiveDecay:(BOOL) orSimpleDecay
{
self = [super init];
if( self ) {
    opcode = @"pluck";
    amplitude = amp;
    pitch = pch;
    pitchDecayBuffer = hz;
    functionTable = f;
    
    //Recursive or Simple decay
    decayMethod = orSimpleDecay ? @"1" : @"6";
    
    roughness = nil;
    stretchFactor = nil;
    currentSampleWeight = nil;
    stretchFactor = nil;
}
return self;
}


-(id)initWithAmplitude:(NSString *)amp
                 Pitch:(NSString *) pch
    DecayedPitchBuffer:(NSString *) hz
         FunctionTable:(CSDFunctionTable *) f
StretchedAveragingDecay:( NSString *) stretchScaler
{
    self = [super init];
    if( self ) {
        opcode = @"pluck";
        amplitude = amp;
        pitch = pch;
        pitchDecayBuffer = hz;
        functionTable = f;
        
        decayMethod = @"2";
        
        stretchFactor = stretchScaler;
        
        roughness = nil;
        currentSampleWeight = nil;
        stretchFactor = nil;
    }
    return self;
}

-(id)initWithAmplitude:(NSString *)amp
                 Pitch:(NSString *) pch
    DecayedPitchBuffer:(NSString *) hz
         FunctionTable:(CSDFunctionTable *) f
       SimpleDrumDecay:( NSString *) roughWeight
{
    self = [super init];
    if( self ) {
        opcode = @"pluck";
        amplitude = amp;
        pitch = pch;
        pitchDecayBuffer = hz;
        functionTable = f;
    
        decayMethod = @"3";
        roughness = roughWeight;
        
        stretchFactor = nil;
        currentSampleWeight = nil;
        stretchFactor = nil;
    }
    return self;
}

-(id)initWithAmplitude:(NSString *)amp
                 Pitch:(NSString *) pch
    DecayedPitchBuffer:(NSString *) hz
         FunctionTable:(CSDFunctionTable *) f
    StretchedDrumDecay:( NSString *) roughWeight
         StretchFactor:( NSString *)stretchScaler
{
    self = [super init];
    if( self ) {
        opcode = @"pluck";
        amplitude = amp;
        pitch = pch;
        pitchDecayBuffer = hz;
        functionTable = f;
    
        decayMethod = @"4";
        roughness = roughWeight;
        stretchFactor = stretchScaler;
        
        currentSampleWeight = nil;
        stretchFactor = nil;
    }
    return self;
}

-(id)initWithAmplitude:(NSString *)amp
                 Pitch:(NSString *) pch
    DecayedPitchBuffer:(NSString *) hz
         FunctionTable:(CSDFunctionTable *) f
  WeightedAverageDecay:( NSString *) currSampleWeight
         StretchFactor:( NSString *)prevSampleWeight
{
    self = [super init];
    if( self ) {
        opcode = @"pluck";
        amplitude = amp;
        pitch = pch;
        pitchDecayBuffer = hz;
        functionTable = f;
    
        decayMethod = @"5";
        currentSampleWeight = currSampleWeight;
        stretchFactor = prevSampleWeight;
    }
    return self;
}

@end
