//
//  OCSPluckString.m
//
//  Created by Aurelius Prochazka on 6/25/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSPluckString.h"

typedef enum
{
    kDecayTypeSimpleAveraging=1,
    kDecayTypeStretchedAveraging=2,
    kDecayTypeWeightedAveraging=5,
    kDecayTypeRecursiveFirstOrder=6
}PluckStringDecayType;

@interface OCSPluckString () {
    OCSParamControl *amp;
    OCSParamControl *resampFreq;
    OCSParamConstant *decayFreq;
    OCSParamConstant *buffer;
    PluckStringDecayType type;
    OCSParamConstant *param1;
    OCSParamConstant *param2;
    
    OCSParam *output;
}
@end

@implementation OCSPluckString

@synthesize output;

- (id) initWithAmplitude:(OCSParamControl *)amplitude
     ResamplingFrequency:(OCSParamControl *)resamplingFrequency
     PitchDecayFrequency:(OCSParamConstant *)pitchDecayFrequency
             AudioBuffer:(OCSParamConstant *)audioBuffer
               DecayType:(PluckStringDecayType) decayType
                  Param1:(OCSParamConstant *)parameter1
                  Param2:(OCSParamConstant *)parameter2 
{
    self = [super init];
    if( self ) {
        output = [OCSParam paramWithString:[self opcodeName]];
        amp = amplitude;
        resampFreq = resamplingFrequency;
        decayFreq  = pitchDecayFrequency;
        buffer = audioBuffer;
        type = decayType;
        param1 = parameter1;
        param2 = parameter2;
    }
    return self;
    
}

- (id) initWithSimpleAveragingDecayAndAmplitude:(OCSParamControl *)amplitude
                            ResamplingFrequency:(OCSParamControl *)resamplingFrequency
                            PitchDecayFrequency:(OCSParamConstant *)pitchDecayFrequency
                                    AudioBuffer:(OCSParamConstant *)audioBuffer 
{
    return [self initWithAmplitude:amplitude 
               ResamplingFrequency:resamplingFrequency 
               PitchDecayFrequency:pitchDecayFrequency 
                       AudioBuffer:audioBuffer 
                         DecayType:kDecayTypeSimpleAveraging 
                            Param1:[OCSParamConstant paramWithInt:0] 
                            Param2:[OCSParamConstant paramWithInt:0]];
}

- (id) initWithStretchedAveragingDecayAndAmplitude:(OCSParamControl *)amplitude
                               ResamplingFrequency:(OCSParamControl *)resamplingFrequency
                               PitchDecayFrequency:(OCSParamConstant *)pitchDecayFrequency
                                       AudioBuffer:(OCSParamConstant *)audioBuffer
                                     StretchFactor:(OCSParamConstant *)stretchFactor 
{
    return [self initWithAmplitude:amplitude 
               ResamplingFrequency:resamplingFrequency 
               PitchDecayFrequency:pitchDecayFrequency 
                       AudioBuffer:audioBuffer 
                         DecayType:kDecayTypeStretchedAveraging 
                            Param1:stretchFactor
                            Param2:[OCSParamConstant paramWithInt:0]];
}


- (id) initWithWeightedAveragingDecayAndAmplitude:(OCSParamControl *)amplitude
                              ResamplingFrequency:(OCSParamControl *)resamplingFrequency
                              PitchDecayFrequency:(OCSParamConstant *)pitchDecayFrequency
                                      AudioBuffer:(OCSParamConstant *)audioBuffer
                                    CurrentWeight:(OCSParamConstant *)currentWeight
                                   PreviousWeight:(OCSParamConstant *)previousWeight
{
    return [self initWithAmplitude:amplitude 
               ResamplingFrequency:resamplingFrequency 
               PitchDecayFrequency:pitchDecayFrequency 
                       AudioBuffer:audioBuffer 
                         DecayType:kDecayTypeWeightedAveraging 
                            Param1:currentWeight 
                            Param2:previousWeight];
}

- (id) initWithRecursiveFilterDecayAndAmplitude:(OCSParamControl *)amplitude
                            ResamplingFrequency:(OCSParamControl *)resamplingFrequency
                            PitchDecayFrequency:(OCSParamConstant *)pitchDecayFrequency
                                    AudioBuffer:(OCSParamConstant *)audioBuffer
{
    return [self initWithAmplitude:amplitude 
               ResamplingFrequency:resamplingFrequency 
               PitchDecayFrequency:pitchDecayFrequency 
                       AudioBuffer:audioBuffer 
                         DecayType:kDecayTypeRecursiveFirstOrder 
                            Param1:[OCSParamConstant paramWithInt:0] 
                            Param2:[OCSParamConstant paramWithInt:0]];
}



- (NSString *)stringForCSD
{
    return [NSString stringWithFormat:
            @"%@ pluck %@, %@, %@, %@, %i, %@, %@\n",
            output, amp, resampFreq, decayFreq, buffer, type, param1, param2];
}

- (NSString *)description {
    return [output parameterString];
}

@end
