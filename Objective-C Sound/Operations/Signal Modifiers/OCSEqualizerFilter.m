//
//  OCSEqualizerFilter.m
//  Objective-C Sound
//
//  Auto-generated from database on 11/11/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//
//  Implementation of Csound's eqfil:
//  http://www.csounds.com/manual/html/eqfil.html
//

#import "OCSEqualizerFilter.h"

@interface OCSEqualizerFilter () {
    OCSAudio *ain;
    OCSControl *kcf;
    OCSControl *kbw;
    OCSControl *kgain;
}
@end

@implementation OCSEqualizerFilter

- (id)initWithAudioSource:(OCSAudio *)audioSource
          centerFrequency:(OCSControl *)centerFrequency
                bandwidth:(OCSControl *)bandwidth
                     gain:(OCSControl *)gain
{
    self = [super initWithString:[self operationName]];
    if (self) {
        ain = audioSource;
        kcf = centerFrequency;
        kbw = bandwidth;
        kgain = gain;
    }
    return self;
}

- (NSString *)stringForCSD {
    return [NSString stringWithFormat:
            @"%@ eqfil %@, %@, %@, %@",
            self, ain, kcf, kbw, kgain, kgain];
}

@end