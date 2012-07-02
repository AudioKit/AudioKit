//
//  OCSPluckDrum.m
//
//  Created by Aurelius Prochazka on 6/25/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSPluckDrum.h"

@interface OCSPluckDrum () {
    OCSControlParam *amp;
    OCSControlParam *resampFreq;
    OCSConstantParam *decayFreq;
    OCSConstantParam *buffer;
    OCSConstantParam *roughness;
    OCSConstantParam *stretch;
    
    OCSParam *output;
}
@end

typedef enum
{
    kDecayTypeSimpleDrum=3,
    kDecayTypeStretchedDrum=4,
} PluckDrumDecayType;

@implementation OCSPluckDrum

@synthesize output;
- (id)initWithAmplitude:(OCSControlParam *)amplitude
    resamplingFrequency:(OCSControlParam *)resamplingFrequency
    pitchDecayFrequency:(OCSConstantParam *)pitchDecayFrequency
            audioBuffer:(OCSConstantParam *)audioBuffer
        roughnessFactor:(OCSConstantParam *)roughnessFactor
          stretchFactor:(OCSConstantParam *)stretchFactor;
{
    self = [super init];
    if( self ) {
        output = [OCSParam paramWithString:[self opcodeName]];
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
