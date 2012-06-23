//
//  UDOCompressor.m
//  ExampleProject
//
//  Created by Aurelius Prochazka on 6/22/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "UDOCompressor.h"

@implementation UDOCompressor

@synthesize outputLeft;
@synthesize outputRight;

- (NSString *)csdDefinition 
{
    return @""
    "opcode Compressor, aa, aakkkk"
    "aL, aR, kthresh, kratio, kattack, krel xin"
    "klowknee    init 48"
    "khighknee   init 60"
    "ilook       init 0.050"
    "aOutL       compress aL, aL, kthresh, klowknee, khighknee, kratio, kattack, krel, ilook"
    "aOutR       compress aR, aR, kthresh, klowknee, khighknee, kratio, kattack, krel, ilook"
    "xout aOutL, aOutR";
}

- (id)initWithInputLeft:(OCSParam *)inL
             InputRight:(OCSParam *)inR
              Threshold:(OCSParamControl *)thr
                  Ratio:(OCSParamControl *)rat 
                 Attack:(OCSParamControl *)atk
                Release:(OCSParamControl *)rel
{
    self = [super init];
    if (self) {
        outputLeft  = [OCSParam paramWithString:[NSString stringWithFormat:@"%@%@",[self opcodeName], @"L"]];
        outputRight = [OCSParam paramWithString:[NSString stringWithFormat:@"%@%@",[self opcodeName], @"R"]];
        inputLeft   = inL;
        inputRight  = inR;
        threshold   = thr;
        ratio       = rat;
        attack      = atk;
        release     = rel;
    }
    return self; 
}

- (NSString *)convertToCsd
{
    return [NSString stringWithFormat:
            @"%@, %@ reverbsc %@, %@, %@, %@, %@, %@\n",
            outputLeft, outputRight, inputLeft, inputRight, threshold, ratio, attack, release];
}


@end
