//
//  OCSBalance.m
//  Objective-C Sound
//
//  Auto-generated from database on 12/24/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//
//  Implementation of Csound's balance:
//  http://www.csounds.com/manual/html/balance.html
//

#import "OCSBalance.h"

@interface OCSBalance () {
    OCSAudio *asig;
    OCSAudio *acomp;
    OCSConstant *ihp;
}
@end

@implementation OCSBalance

- (instancetype)initWithAudioSource:(OCSAudio *)audioSource
    comparatorAudioSource:(OCSAudio *)comparatorAudioSource
{
    self = [super initWithString:[self operationName]];
    if (self) {
        asig = audioSource;
        acomp = comparatorAudioSource;
        ihp = ocsp(10);
    }
    return self;
}

- (void)setOptionalHalfPowerPoint:(OCSConstant *)halfPowerPoint {
	ihp = halfPowerPoint;
}

- (NSString *)stringForCSD {
    return [NSString stringWithFormat:
            @"%@ balance %@, %@, %@",
            self, asig, acomp, ihp];
}

@end