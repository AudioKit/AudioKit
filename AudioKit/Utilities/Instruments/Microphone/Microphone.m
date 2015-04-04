//
//  Microphone.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 4/4/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "Microphone.h"

@implementation Microphone

- (instancetype)init
{
    self = [super init];
    if (self) {
        AKAudioInput *microphone = [[AKAudioInput alloc] init];
        _auxilliaryOutput = [AKAudio globalParameter];
        [self assignOutput:_auxilliaryOutput to:microphone];
    }
    return self;
}

@end
