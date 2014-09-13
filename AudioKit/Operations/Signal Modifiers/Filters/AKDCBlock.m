//
//  AKDCBlock.m
//  AudioKit
//
//  Auto-generated from scripts by Aurelius Prochazka on 12/25/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//
//  Implementation of Csound's dcblock:
//  http://www.csounds.com/manual/html/dcblock.html
//

#import "AKDCBlock.h"

@implementation AKDCBlock
{
    AKAudio *ain;
    AKConstant *igain;
}

- (instancetype)initWithAudioSource:(AKAudio *)audioSource
{
    self = [super initWithString:[self operationName]];
    if (self) {
        ain = audioSource;
        igain = akp(0.99);
    }
    return self;
}

- (void)setOptionalGain:(AKConstant *)gain {
	igain = gain;
}

- (NSString *)stringForCSD {
    return [NSString stringWithFormat:
            @"%@ dcblock %@, %@",
            self, ain, igain];
}

@end