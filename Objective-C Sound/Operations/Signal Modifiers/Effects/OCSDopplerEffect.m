//
//  OCSDopplerEffect.m
//  Objective-C Sound
//
//  Auto-generated from database on 11/24/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//
//  Implementation of Csound's doppler:
//  http://www.csounds.com/manual/html/doppler.html
//

#import "OCSDopplerEffect.h"

@interface OCSDopplerEffect () {
    OCSAudio *asource;
    OCSControl *kmicposition;
    OCSControl *ksourceposition;
    OCSConstant *isoundspeed;
    OCSConstant *ifiltercutoff;
}
@end

@implementation OCSDopplerEffect

- (instancetype)initWithAudioSource:(OCSAudio *)audioSource
                        micPosition:(OCSControl *)micPosition
                     sourcePosition:(OCSControl *)sourcePosition
{
    self = [super initWithString:[self operationName]];
    if (self) {
        asource = audioSource;
        kmicposition = micPosition;
        ksourceposition = sourcePosition;
        isoundspeed = ocsp(340.29);
        ifiltercutoff = ocsp(6);
    }
    return self;
}

- (void)setOptionalSoundSpeed:(OCSConstant *)soundSpeed {
	isoundspeed = soundSpeed;
}

- (void)setOptionalSmoothingFilterUpdateRate:(OCSConstant *)smoothingFilterUpdateRate {
	ifiltercutoff = smoothingFilterUpdateRate;
}

- (NSString *)stringForCSD {
    return [NSString stringWithFormat:
            @"%@ doppler %@, %@, %@, %@, %@",
            self, asource, ksourceposition, kmicposition, isoundspeed, ifiltercutoff];
}

@end