//
//  OCSPluckDrum.m
//  Objective-Csound
//
//  Created by Aurelius Prochazka on 6/25/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSPluckDrum.h"

@interface OCSPluckDrum () {
    OCSControl *amp;
    OCSControl *resampFreq;
    OCSConstant *decayFreq;
    OCSConstant *buffer;
    OCSConstant *roughness;
    OCSConstant *stretch;
    
    OCSParameter *output;
}
@end

typedef enum
{
    kDecayTypeSimpleDrum=3,
    kDecayTypeStretchedDrum=4,
} PluckDrumDecayType;

@implementation OCSPluckDrum

@synthesize output;
- (id)initWithAmplitude:(OCSControl *)amplitude
    resamplingFrequency:(OCSControl *)resamplingFrequency
    pitchDecayFrequency:(OCSConstant *)pitchDecayFrequency
            audioBuffer:(OCSConstant *)audioBuffer
        roughnessFactor:(OCSConstant *)roughnessFactor
          stretchFactor:(OCSConstant *)stretchFactor;
{
    self = [super init];
    if( self ) {
        output = [OCSParameter parameterWithString:[self opcodeName]];
        amp = amplitude;
        resampFreq = resamplingFrequency;
        decayFreq  = pitchDecayFrequency;
        buffer = audioBuffer;
        roughness = roughnessFactor;
        stretch = stretchFactor;
    }
    return self;
}

- (NSString *)stringForCSD
{
    return [NSString stringWithFormat:
            @"%@ pluck %@, %@, %@, %@, %i, %@, %@",
            output, amp, resampFreq, decayFreq, buffer, kDecayTypeStretchedDrum, roughness, stretch];
}

/// Gives the CSD string for the output parameter.  
- (NSString *)description {
    return [output parameterString];
}

@end
