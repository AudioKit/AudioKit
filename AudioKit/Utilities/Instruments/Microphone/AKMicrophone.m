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
        _amplitude = [self createPropertyWithValue:1 minimum:0 maximum:1000];

        AKAudioInput *microphone = [[AKAudioInput alloc] init];
        _output = [AKAudio globalParameter];
        [self assignOutput:_output to:[microphone scaledBy:_amplitude]];
    }
    return self;
}

@end
