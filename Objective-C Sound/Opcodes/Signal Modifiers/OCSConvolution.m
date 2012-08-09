//
//  OCSConvolution.m
//  Objective-C Sound
//
//  Created by Aurelius Prochazka on 6/27/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSConvolution.h"

@interface OCSConvolution () {
    OCSParameter *output;
    OCSParameter *ain;
    NSString *ifilcod;
}
@end

@implementation OCSConvolution

@synthesize output;

- (id)initWithInputAudio:(OCSParameter *)inputAudio 
     impulseResponseFile:(NSString *)impulseResponseFilename;
{
    self = [super init];
    if (self) {
        output  =  [OCSParameter parameterWithString:[self opcodeName]];
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
