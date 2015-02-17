//
//  VocalInput.m
//  AudioKitDemo
//
//  Created by Aurelius Prochazka on 2/14/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "VocalInput.h"

@implementation VocalInput

- (instancetype)init
{
    self = [super init];
    if (self) {
        AKAudioInput *microphone = [[AKAudioInput alloc] init];
        [self connect:microphone];
        _auxilliaryOutput = [AKAudio globalParameter];
        [self assignOutput:_auxilliaryOutput to:microphone];
    }
    return self;
}

@end