//
//  OCSDCBlock.m
//  Objective-C Sound
//
//  Auto-generated from database on 12/25/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//
//  Implementation of Csound's dcblock:
//  http://www.csounds.com/manual/html/dcblock.html
//

#import "OCSDCBlock.h"

@interface OCSDCBlock () {
    OCSAudio *ain;
    OCSConstant *igain;
}
@end

@implementation OCSDCBlock

- (id)initWithAudioSource:(OCSAudio *)audioSource
{
    self = [super initWithString:[self operationName]];
    if (self) {
        ain = audioSource;
        igain = ocsp(0.99);
    }
    return self;
}

- (void)setOptionalGain:(OCSConstant *)gain {
	igain = gain;
}

- (NSString *)stringForCSD {
    return [NSString stringWithFormat:
            @"%@ dcblock %@, %@",
            self, ain, igain];
}

@end