//
//  OCSTrackedAmplitude.m
//  Objective-C Sound
//
//  Created by Aurelius Prochazka on 11/12/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSTrackedAmplitude.h"

@interface OCSTrackedAmplitude () {
    OCSAudio *asig;
}
@end

@implementation OCSTrackedAmplitude

- (id)initWithAudioSource:(OCSAudio *)audioSource
{
    self = [super initWithString:[self operationName]];
    if (self) {
        asig = audioSource;
    }
    return self;
}

- (NSString *)stringForCSD {
    return [NSString stringWithFormat:
            @"%@ rms %@",
            self, asig];
}

@end
