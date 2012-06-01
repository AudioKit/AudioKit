//
//  CSDPluck.m
//  ExampleProject
//
//  Created by Adam Boulanger on 6/1/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "CSDPluck.h"

@implementation CSDPluck
@synthesize output;
@synthesize opcode;
@synthesize amplitude;
@synthesize pitch;
@synthesize functionTable;

@synthesize decayMethod;
@synthesize roughness;
@synthesize stretchFactor;
@synthesize currentSampleWeight;
@synthesize previousSampleWeight;


-(NSString *) textWithPValue:(int)p
{
    //ARB - TODO: go back and look at optional parameter declaration suitable for return as string
    //  from single conditional block in this method
}

-(id)initWithOutput:(NSString *)out
Amplitude:(NSString *)amp
Pitch:(NSString *) pch
FunctionTable:(CSDFunctionStatement *) f
AndRecursiveDecay:(BOOL) orSimpleDecay
{
self = [super init];
if( self ) {
    opcode = @"pluck";
    output = out;
    amplitude = amp;
    pitch = pch;
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


-(id)initWithOutput:(NSString *)out
Amplitude:(NSString *)amp
Pitch:(NSString *) pch
FunctionTable:(CSDFunctionStatement *) f
AndStretchedAveragingDecay:( NSString *) stretchScaler
{
    self = [super init];
    if( self ) {
        opcode = @"pluck";
        output = out;
        amplitude = amp;
        pitch = pch;
        functionTable = f;
        
        decayMethod = @"2";
        stretchFactor = stretchScaler;
        
        roughness = nil;
        currentSampleWeight = nil;
        stretchFactor = nil;
    }
    return self;
}

-(id)initWithOutput:(NSString *)out
Amplitude:(NSString *)amp
Pitch:(NSString *) pch
FunctionTable:(CSDFunctionStatement *) f
AndSimpleDrumDecay:( NSString *) roughWeight
{
    self = [super init];
    if( self ) {
        opcode = @"pluck";
        output = out;
        amplitude = amp;
        pitch = pch;
        functionTable = f;
    
        decayMethod = @"3";
        roughness = roughWeight;
        
        stretchFactor = nil;
        currentSampleWeight = nil;
        stretchFactor = nil;
    }
    return self;
}

-(id)initWithOutput:(NSString *)out
Amplitude:(NSString *)amp
Pitch:(NSString *) pch
FunctionTable:(CSDFunctionStatement *) f
AndStretchedDrumDecay:( NSString *) roughWeight
StretchFactor:( NSString *)stretchScaler
{
    self = [super init];
    if( self ) {
        opcode = @"pluck";
        output = out;
        amplitude = amp;
        pitch = pch;
        functionTable = f;
    
        decayMethod = @"4";
        roughness = roughWeight;
        stretchFactor = stretchScaler;
        
        currentSampleWeight = nil;
        stretchFactor = nil;
    }
    return self;
}

-(id)initWithOutput:(NSString *)out
Amplitude:(NSString *)amp
Pitch:(NSString *) pch
FunctionTable:(CSDFunctionStatement *) f
AndWeightedAverageDecay:( NSString *) currSampleWeight
StretchFactor:( NSString *)prevSampleWeight
{
    self = [super init];
    if( self ) {
        opcode = @"pluck";
        output = out;
        amplitude = amp;
        pitch = pch;
        functionTable = f;
    
        decayMethod = @"5";
        currentSampleWeight = currSampleWeight;
        stretchFactor = prevSampleWeight;
    }
    return self;
}

@end
