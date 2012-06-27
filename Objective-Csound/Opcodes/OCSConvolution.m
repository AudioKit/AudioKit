//
//  OCSConvolution.m
//
//  Created by Aurelius Prochazka on 6/27/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSConvolve.h"

@interface OCSConvolution () {
    OCSParam *output
    OCSParam *ain;
    OCSParamConstant *ifilcod;
}
@end

@implementation OCSConvolution

@synthesize output;

- (id)initWithInputAudio:(OCSParam *)inputAudio 
     impulseResponseFile:(OCSParamConstant *)impulseResponseFile 
{
    self = [super init];
    if (self) {
        output  =  [OCSParam paramWithString:[self opcodeName]];
        ain     = inputAudio;
        ifilcod = impulseResponseFile;
    }
    return self; 
}

- (NSString *)stringForCSD
{
    return [NSString stringWithFormat:
            @"%@, %@ pconvolve %@, %@ \n",
            output, ain, ifilcod];
}

@end
