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
     resamplingFrequency:(OCSParamControl *)resamplingFrequency
     pitchDecayFrequency:(OCSParamConstant *)pitchDecayFrequency
             audioBuffer:(OCSParamConstant *)audioBuffer
               decayType:(PluckStringDecayType) decayType
                  param1:(OCSParamConstant *)parameter1
                  param2:(OCSParamConstant *)parameter2 
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
                            resamplingFrequency:(OCSParamControl *)resamplingFrequency
                            pitchDecayFrequency:(OCSParamConstant *)pitchDecayFrequency
                                    audioBuffer:(OCSParamConstant *)audioBuffer 
{
    return [self initWithAmplitude:amplitude 
               resamplingFrequency:resamplingFrequency 
               pitchDecayFrequency:pitchDecayFrequency 
                       audioBuffer:audioBuffer 
                         decayType:kDecayTypeSimpleAveraging 
                            param1:[OCSParamConstant paramWithInt:0] 
                            param2:[OCSParamConstant paramWithInt:0]];
}

- (id) initWithStretchedAveragingDecayAndAmplitude:(OCSParamControl *)amplitude
                               resamplingFrequency:(OCSParamControl *)resamplingFrequency
                               pitchDecayFrequency:(OCSParamConstant *)pitchDecayFrequency
                                       audioBuffer:(OCSParamConstant *)audioBuffer
                                     stretchFactor:(OCSParamConstant *)stretchFactor 
{
    return [self initWithAmplitude:amplitude 
               resamplingFrequency:resamplingFrequency 
               pitchDecayFrequency:pitchDecayFrequency 
                       audioBuffer:audioBuffer 
                         decayType:kDecayTypeStretchedAveraging 
                            param1:stretchFactor
                            param2:[OCSParamConstant paramWithInt:0]];
}


- (id) initWithWeightedAveragingDecayAndAmplitude:(OCSParamControl *)amplitude
                              resamplingFrequency:(OCSParamControl *)resamplingFrequency
                              pitchDecayFrequency:(OCSParamConstant *)pitchDecayFrequency
                                      audioBuffer:(OCSParamConstant *)audioBuffer
                                    currentWeight:(OCSParamConstant *)currentWeight
                                   previousWeight:(OCSParamConstant *)previousWeight
{
    return [self initWithAmplitude:amplitude 
               resamplingFrequency:resamplingFrequency 
               pitchDecayFrequency:pitchDecayFrequency 
                       audioBuffer:audioBuffer 
                         decayType:kDecayTypeWeightedAveraging 
                            param1:currentWeight 
                            param2:previousWeight];
}

- (id) initWithRecursiveFilterDecayAndAmplitude:(OCSParamControl *)amplitude
                            resamplingFrequency:(OCSParamControl *)resamplingFrequency
                            pitchDecayFrequency:(OCSParamConstant *)pitchDecayFrequency
                                    audioBuffer:(OCSParamConstant *)audioBuffer
{
    return [self initWithAmplitude:amplitude 
               resamplingFrequency:resamplingFrequency 
               pitchDecayFrequency:pitchDecayFrequency 
                       audioBuffer:audioBuffer 
                         decayType:kDecayTypeRecursiveFirstOrder 
                            param1:[OCSParamConstant paramWithInt:0] 
                            param2:[OCSParamConstant paramWithInt:0]];
}



- (NSString *)stringForCSD
{
    return [NSString stringWithFormat:
            @"%@ pluck %@, %@, %@, %@, %i, %@, %@\n",
            output, amp, resampFreq, decayFreq, buffer, type, param1, param2];
}

/// Gives the CSD string for the output parameter.  
- (NSString *)description {
    return [output parameterString];
}

@end
