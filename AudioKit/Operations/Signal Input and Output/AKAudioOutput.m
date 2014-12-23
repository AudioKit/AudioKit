//
//  AKAudioOutput.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 6/9/12.
//  Copyright (c) 2012 Aurelius Prochazka. All rights reserved.
//

#import "AKAudioOutput.h"

@implementation AKAudioOutput
{
    AKStereoAudio *aStereoOutput;
}

- (instancetype)initWithAudioSource:(AKAudio *)audioSource
{
    return [self initWithLeftAudio:audioSource rightAudio:audioSource];
}

- (instancetype)initWithStereoAudioSource:(AKStereoAudio *)stereoAudio {
    self = [super initWithString:[self operationName]];
    if (self) {
        aStereoOutput = stereoAudio;
    }
    return self;
}

- (instancetype)initWithLeftAudio:(AKAudio *)leftAudio
                       rightAudio:(AKAudio *)rightAudio
{
    self = [super initWithString:[self operationName]];
    if (self) {
        aStereoOutput = [[AKStereoAudio alloc] initWithLeftAudio:leftAudio
                                                      rightAudio:rightAudio];
    }
    return self; 
}

// Csound prototype: outs asig1, asig2
- (NSString *)stringForCSD {
    return [NSString stringWithFormat:@"outs %@", aStereoOutput];
}

@end
