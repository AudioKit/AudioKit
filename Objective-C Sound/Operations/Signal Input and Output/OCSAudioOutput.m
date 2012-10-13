//
//  OCSAudioOutput.m
//  Objective-C Sound
//
//  Created by Aurelius Prochazka on 6/9/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSAudioOutput.h"

@interface OCSAudioOutput () {
    OCSStereoAudio *aStereoOutput;
}
@end

@implementation OCSAudioOutput

- (id)initWithMonoInput:(OCSAudio *)monoSignal
{
    return [self initWithLeftInput:monoSignal rightInput:monoSignal];
}

- (id)initWithStereoInput:(OCSStereoAudio *)stereoSignal {
    self = [super init];
    if (self) {
        aStereoOutput = stereoSignal;
    }
    return self;
}

- (id)initWithLeftInput:(OCSAudio *)leftInput rightInput:(OCSAudio *)rightInput
{
    self = [super init];
    if (self) {
        aStereoOutput = [[OCSStereoAudio alloc] initWithLeftInput:leftInput rightInput:rightInput];
    }
    return self; 
}

// Csound prototype: outs asig1, asig2
- (NSString *)stringForCSD {
    return [NSString stringWithFormat:@"outs %@", aStereoOutput];
}

@end
