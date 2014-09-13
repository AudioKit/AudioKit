//
//  AKDopplerEffect.m
//  AudioKit
//
//  Auto-generated from scripts by Aurelius Prochazka on 11/24/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//
//  Implementation of Csound's doppler:
//  http://www.csounds.com/manual/html/doppler.html
//

#import "AKDopplerEffect.h"

@implementation AKDopplerEffect
{
    AKAudio *asource;
    AKControl *kmicposition;
    AKControl *ksourceposition;
    AKConstant *isoundspeed;
    AKConstant *ifiltercutoff;
}

- (instancetype)initWithAudioSource:(AKAudio *)audioSource
                        micPosition:(AKControl *)micPosition
                     sourcePosition:(AKControl *)sourcePosition
{
    self = [super initWithString:[self operationName]];
    if (self) {
        asource = audioSource;
        kmicposition = micPosition;
        ksourceposition = sourcePosition;
        isoundspeed = akp(340.29);
        ifiltercutoff = akp(6);
    }
    return self;
}

- (void)setOptionalSoundSpeed:(AKConstant *)soundSpeed {
	isoundspeed = soundSpeed;
}

- (void)setOptionalSmoothingFilterUpdateRate:(AKConstant *)smoothingFilterUpdateRate {
	ifiltercutoff = smoothingFilterUpdateRate;
}

- (NSString *)stringForCSD {
    return [NSString stringWithFormat:
            @"%@ doppler %@, %@, %@, %@, %@",
            self, asource, ksourceposition, kmicposition, isoundspeed, ifiltercutoff];
}

@end