//
//  OCSPluckDrum.m
//
//  Created by Aurelius Prochazka on 6/25/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSPluckDrum.h"

@interface OCSPluckDrum () {
    OCSParamControl *amp;
    OCSParamControl *resampFreq;
    OCSParamConstant *decayFreq;
    OCSParamConstant *buffer;
    OCSParamConstant *roughness;
    OCSParamConstant *stretch;
    
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
- (id)initWithAmplitude:(OCSParamControl *)amplitude
    ResamplingFrequency:(OCSParamControl *)resamplingFrequency
    PitchDecayFrequency:(OCSParamConstant *)pitchDecayFrequency
            AudioBuffer:(OCSParamConstant *)audioBuffer
        RoughnessFactor:(OCSParamConstant *)roughnessFactor
          StretchFactor:(OCSParamConstant *)stretchFactor
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
            @"%@ pluck %@, %@, %@, %@, %i, %@, %@\n",
            output, amp, resampFreq, decayFreq, buffer, kDecayTypeStretchedDrum, roughness, stretch];
}

- (NSString *)description {
    return [output parameterString];
}

@end
