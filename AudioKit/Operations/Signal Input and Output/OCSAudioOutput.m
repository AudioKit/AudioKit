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

- (instancetype)initWithAudioSource:(OCSAudio *)audioSource
{
    return [self initWithLeftAudio:audioSource rightAudio:audioSource];
}

- (instancetype)initWithSourceStereoAudio:(OCSStereoAudio *)stereoAudio {
    self = [super init];
    if (self) {
        aStereoOutput = stereoAudio;
    }
    return self;
}

- (instancetype)initWithLeftAudio:(OCSAudio *)leftAudio
                       rightAudio:(OCSAudio *)rightAudio
{
    self = [super init];
    if (self) {
        aStereoOutput = [[OCSStereoAudio alloc] initWithLeftAudio:leftAudio
                                                       rightAudio:rightAudio];
    }
    return self; 
}

// Csound prototype: outs asig1, asig2
- (NSString *)stringForCSD {
    return [NSString stringWithFormat:@"outs %@", aStereoOutput];
}

@end
