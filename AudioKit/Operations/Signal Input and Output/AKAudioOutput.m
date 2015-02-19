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

- (instancetype)initWithInput:(AKParameter *)source
{
    return [self initWithLeftAudio:source rightAudio:source];
}

- (instancetype)initWithAudioSource:(AKParameter *)audioSource
{
    return [self initWithLeftAudio:audioSource rightAudio:audioSource];
}

- (instancetype)initWithStereoAudioSource:(AKStereoAudio *)stereoAudio {
    self = [super initWithString:[self operationName]];
    if (self) {
        aStereoOutput = stereoAudio;
        self.state = @"connectable";
        self.dependencies = @[stereoAudio];
    }
    return self;
}

- (instancetype)initWithLeftAudio:(AKParameter *)leftAudio
                       rightAudio:(AKParameter *)rightAudio
{
    self = [super initWithString:[self operationName]];
    if (self) {
        aStereoOutput = [[AKStereoAudio alloc] initWithLeftAudio:leftAudio
                                                      rightAudio:rightAudio];
        self.state = @"connectable";
        self.dependencies = @[leftAudio, rightAudio];
    }
    return self; 
}

// Csound prototype: outs asig1, asig2
- (NSString *)stringForCSD {
    return [NSString stringWithFormat:@"outs %@", aStereoOutput];
}

@end
