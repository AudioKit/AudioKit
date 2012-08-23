//
//  OCSConvolution.m
//  Objective-C Sound
//
//  Created by Aurelius Prochazka on 6/27/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSConvolution.h"

@interface OCSConvolution () {
    OCSParameter *aR1;
    OCSParameter *aIn;
    NSString *iFilCod;
}
@end

@implementation OCSConvolution

@synthesize output = aR1;

- (id)initWithInputAudio:(OCSParameter *)inputAudio 
     impulseResponseFile:(NSString *)impulseResponseFilename;
{
    self = [super init];
    if (self) {
        aR1     =  [OCSParameter parameterWithString:[self opcodeName]];
        aIn     = inputAudio;
        iFilCod = impulseResponseFilename;
    }
    return self; 
}

// Csound prototype: ar1 [, ar2] [, ar3] [, ar4] pconvolve ain, ifilcod [, ipartitionsize, ichannel]
- (NSString *)stringForCSD
{
    return [NSString stringWithFormat:
            @"%@ pconvolve %@, \"%@\"",
            aR1, aIn, iFilCod];
}

@end
