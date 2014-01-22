//
//  OCSStereoConvolution.m
//  Objective-C Sound
//
//  Created by Aurelius Prochazka on 6/27/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSStereoConvolution.h"

@interface OCSStereoConvolution () {
    OCSAudio *aIn;
    NSString *iFilCod;
}
@end

@implementation OCSStereoConvolution

- (instancetype)initWithAudioSource:(OCSAudio *)audioSource
                impulseResponseFile:(NSString *)impulseResponseFilename;
{
    self = [super init];
    if (self) {
        aIn     = audioSource;
        iFilCod = impulseResponseFilename;
    }
    return self;
}

// Csound prototype: ar1 [, ar2] [, ar3] [, ar4] pconvolve ain, ifilcod [, ipartitionsize, ichannel]
- (NSString *)stringForCSD
{
    return [NSString stringWithFormat:
            @"%@ pconvolve %@, \"%@\"",
            self, aIn, iFilCod];
}

@end
