//
//  Microphone.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 4/4/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKMicrophone.h"

@implementation AKMicrophone

- (instancetype)init
{
    self = [super init];
    if (self) {
        AKAudioInput *microphone = [[AKAudioInput alloc] init];
        _output = [AKAudio globalParameter];
        [self assignOutput:_output to:microphone];
    }
    return self;
}

@end
