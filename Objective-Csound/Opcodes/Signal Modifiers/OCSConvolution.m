//
//  OCSConvolution.m
//
//  Created by Aurelius Prochazka on 6/27/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSConvolution.h"

@interface OCSConvolution () {
    OCSParam *output;
    OCSParam *ain;
    NSString *ifilcod;
}
@end

@implementation OCSConvolution

@synthesize output;

- (id)initWithInputAudio:(OCSParam *)inputAudio 
     impulseResponseFile:(NSString *)impulseResponseFilename;
{
    self = [super init];
    if (self) {
        output  =  [OCSParam paramWithString:[self opcodeName]];
        ain     = inputAudio;
        ifilcod = impulseResponseFilename;
    }
    return self; 
}

- (NSString *)stringForCSD
{
    return [NSString stringWithFormat:
            @"%@ pconvolve %@, \"%@\"",
            output, ain, ifilcod];
}

@end
