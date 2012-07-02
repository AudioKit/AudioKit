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
    OCSControlParam *amp;
    OCSControlParam *resampFreq;
    OCSConstantParam *decayFreq;
    OCSConstantParam *buffer;
    PluckStringDecayType type;
    OCSConstantParam *param1;
    OCSConstantParam *param2;
    
    OCSParam *output;
}
@end

@implementation OCSPluckString

@synthesize output;

- (id) initWithAmplitude:(OCSControlParam *)amplitude
     resamplingFrequency:(OCSControlParam *)resamplingFrequency
     pitchDecayFrequency:(OCSConstantParam *)pitchDecayFrequency
             audioBuffer:(OCSConstantParam *)audioBuffer
               decayType:(PluckStringDecayType) decayType
                  param1:(OCSConstantParam *)parameter1
                  param2:(OCSConstantParam *)parameter2 
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

- (id) initWithSimpleAveragingDecayAndAmplitude:(OCSControlParam *)amplitude
                            resamplingFrequency:(OCSControlParam *)resamplingFrequency
                            pitchDecayFrequency:(OCSConstantParam *)pitchDecayFrequency
                                    audioBuffer:(OCSConstantParam *)audioBuffer 
{
    return [self initWithAmplitude:amplitude 
               resamplingFrequency:resamplingFrequency 
               pitchDecayFrequency:pitchDecayFrequency 
                       audioBuffer:audioBuffer 
                         decayType:kDecayTypeSimpleAveraging 
                            param1:[OCSConstantParam paramWithInt:0] 
                            param2:[OCSConstantParam paramWithInt:0]];
}

- (id) initWithStretchedAveragingDecayAndAmplitude:(OCSControlParam *)amplitude
                               resamplingFrequency:(OCSControlParam *)resamplingFrequency
                               pitchDecayFrequency:(OCSConstantParam *)pitchDecayFrequency
                                       audioBuffer:(OCSConstantParam *)audioBuffer
                                     stretchFactor:(OCSConstantParam *)stretchFactor 
{
    return [self initWithAmplitude:amplitude 
               resamplingFrequency:resamplingFrequency 
               pitchDecayFrequency:pitchDecayFrequency 
                       audioBuffer:audioBuffer 
                         decayType:kDecayTypeStretchedAveraging 
                            param1:stretchFactor
                            param2:[OCSConstantParam paramWithInt:0]];
}


- (id) initWithWeightedAveragingDecayAndAmplitude:(OCSControlParam *)amplitude
                              resamplingFrequency:(OCSControlParam *)resamplingFrequency
                              pitchDecayFrequency:(OCSConstantParam *)pitchDecayFrequency
                                      audioBuffer:(OCSConstantParam *)audioBuffer
                                    currentWeight:(OCSConstantParam *)currentWeight
                                   previousWeight:(OCSConstantParam *)previousWeight
{
    return [self initWithAmplitude:amplitude 
               resamplingFrequency:resamplingFrequency 
               pitchDecayFrequency:pitchDecayFrequency 
                       audioBuffer:audioBuffer 
                         decayType:kDecayTypeWeightedAveraging 
                            param1:currentWeight 
                            param2:previousWeight];
}

- (id) initWithRecursiveFilterDecayAndAmplitude:(OCSControlParam *)amplitude
                            resamplingFrequency:(OCSControlParam *)resamplingFrequency
                            pitchDecayFrequency:(OCSConstantParam *)pitchDecayFrequency
                                    audioBuffer:(OCSConstantParam *)audioBuffer
{
    return [self initWithAmplitude:amplitude 
               resamplingFrequency:resamplingFrequency 
               pitchDecayFrequency:pitchDecayFrequency 
                       audioBuffer:audioBuffer 
                         decayType:kDecayTypeRecursiveFirstOrder 
                            param1:[OCSConstantParam paramWithInt:0] 
                            param2:[OCSConstantParam paramWithInt:0]];
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
