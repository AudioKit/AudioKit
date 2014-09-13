//
//  AKPanner.m
//  AudioKit
//
//  Auto-generated from scripts by Aurelius Prochazka on 11/24/12.
//  Modified by Aurelius Prochazka to add pan methods.
//
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//
//  Implementation of Csound's pan2:
//  http://www.csounds.com/manual/html/pan2.html
//

#import "AKPanner.h"

@implementation AKPanner
{
    AKAudio *asig;
    AKParameter *xp;
    AKConstant *imode;
}

- (instancetype)initWithAudioSource:(AKAudio *)audioSource
                                pan:(AKParameter *)pan
{
    self = [super initWithString:[self operationName]];
    if (self) {
        asig = audioSource;
        xp = pan;
        imode = akpi(kPanEqualPower);
    }
    return self;
}

- (void)setOptionalPanMethod:(PanMethod)panMethod {
	imode = akpi(panMethod);
}

- (NSString *)stringForCSD {
    return [NSString stringWithFormat:
            @"%@ pan2 %@, %@, %@",
            self, asig, xp, imode];
}

@end