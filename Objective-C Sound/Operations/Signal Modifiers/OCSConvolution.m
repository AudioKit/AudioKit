//
//  OCSConvolution.m
//  Objective-C Sound
//
//  Created by Aurelius Prochazka on 6/27/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSConvolution.h"

@interface OCSConvolution () {
    OCSAudio *aIn;
    NSString *iFilCod;
}
@end

@implementation OCSConvolution

- (id)initWithSourceAudio:(OCSAudio *)sourceAudio
      impulseResponseFile:(NSString *)impulseResponseFilename
{
    self = [super initWithString:[self operationName]];
    if (self) {
        aIn     = sourceAudio;
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
