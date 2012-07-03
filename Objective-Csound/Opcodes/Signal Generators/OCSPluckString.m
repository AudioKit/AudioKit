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
    OCSControl *amp;
    OCSControl *resampFreq;
    OCSConstant *decayFreq;
    OCSConstant *buffer;
    PluckStringDecayType type;
    OCSConstant *param1;
    OCSConstant *param2;
    
    OCSParameter *output;
}
@end

@implementation OCSPluckString

@synthesize output;

- (id) initWithAmplitude:(OCSControl *)amplitude
     resamplingFrequency:(OCSControl *)resamplingFrequency
     pitchDecayFrequency:(OCSConstant *)pitchDecayFrequency
             audioBuffer:(OCSConstant *)audioBuffer
               decayType:(PluckStringDecayType) decayType
                  param1:(OCSConstant *)parameter1
                  param2:(OCSConstant *)parameter2 
{
    self = [super init];
    if( self ) {
        output = [OCSParameter parameterWithString:[self opcodeName]];
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

- (id) initWithSimpleAveragingDecayAndAmplitude:(OCSControl *)amplitude
                            resamplingFrequency:(OCSControl *)resamplingFrequency
                            pitchDecayFrequency:(OCSConstant *)pitchDecayFrequency
                                    audioBuffer:(OCSConstant *)audioBuffer 
{
    return [self initWithAmplitude:amplitude 
               resamplingFrequency:resamplingFrequency 
               pitchDecayFrequency:pitchDecayFrequency 
                       audioBuffer:audioBuffer 
                         decayType:kDecayTypeSimpleAveraging 
                            param1:[OCSConstant parameterWithInt:0] 
                            param2:[OCSConstant parameterWithInt:0]];
}

- (id) initWithStretchedAveragingDecayAndAmplitude:(OCSControl *)amplitude
                               resamplingFrequency:(OCSControl *)resamplingFrequency
                               pitchDecayFrequency:(OCSConstant *)pitchDecayFrequency
                                       audioBuffer:(OCSConstant *)audioBuffer
                                     stretchFactor:(OCSConstant *)stretchFactor 
{
    return [self initWithAmplitude:amplitude 
               resamplingFrequency:resamplingFrequency 
               pitchDecayFrequency:pitchDecayFrequency 
                       audioBuffer:audioBuffer 
                         decayType:kDecayTypeStretchedAveraging 
                            param1:stretchFactor
                            param2:[OCSConstant parameterWithInt:0]];
}


- (id) initWithWeightedAveragingDecayAndAmplitude:(OCSControl *)amplitude
                              resamplingFrequency:(OCSControl *)resamplingFrequency
                              pitchDecayFrequency:(OCSConstant *)pitchDecayFrequency
                                      audioBuffer:(OCSConstant *)audioBuffer
                                    currentWeight:(OCSConstant *)currentWeight
                                   previousWeight:(OCSConstant *)previousWeight
{
    return [self initWithAmplitude:amplitude 
               resamplingFrequency:resamplingFrequency 
               pitchDecayFrequency:pitchDecayFrequency 
                       audioBuffer:audioBuffer 
                         decayType:kDecayTypeWeightedAveraging 
                            param1:currentWeight 
                            param2:previousWeight];
}

- (id) initWithRecursiveFilterDecayAndAmplitude:(OCSControl *)amplitude
                            resamplingFrequency:(OCSControl *)resamplingFrequency
                            pitchDecayFrequency:(OCSConstant *)pitchDecayFrequency
                                    audioBuffer:(OCSConstant *)audioBuffer
{
    return [self initWithAmplitude:amplitude 
               resamplingFrequency:resamplingFrequency 
               pitchDecayFrequency:pitchDecayFrequency 
                       audioBuffer:audioBuffer 
                         decayType:kDecayTypeRecursiveFirstOrder 
                            param1:[OCSConstant parameterWithInt:0] 
                            param2:[OCSConstant parameterWithInt:0]];
}



- (NSString *)stringForCSD
{
    return [NSString stringWithFormat:
            @"%@ pluck %@, %@, %@, %@, %i, %@, %@",
            output, amp, resampFreq, decayFreq, buffer, type, param1, param2];
}

/// Gives the CSD string for the output parameter.  
- (NSString *)description {
    return [output parameterString];
}

@end
