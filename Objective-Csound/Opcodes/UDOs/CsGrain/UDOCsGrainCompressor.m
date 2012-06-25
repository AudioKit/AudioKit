//
//  UDOCompressor.m
//  ExampleProject
//
//  Created by Aurelius Prochazka on 6/22/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "UDOCsGrainCompressor.h"


@interface UDOCsGrainCompressor () {
    OCSParam *outputLeft;
    OCSParam *outputRight;
    OCSParam *inL;
    OCSParam *inR;
    OCSParamControl *threshold;
    OCSParamControl *ratio;
    OCSParamControl *attack;
    OCSParamControl *release;
}
@end

@implementation UDOCsGrainCompressor

@synthesize outputLeft;
@synthesize outputRight;

- (id)initWithInputLeft:(OCSParam *)leftInput
             InputRight:(OCSParam *)rightInput
              Threshold:(OCSParamControl *)dBThreshold
       CompressionRatio:(OCSParamControl *)compressionRatio
             AttackTime:(OCSParamControl *)attackTime
            ReleaseTime:(OCSParamControl *)releaseTime;
{
    self = [super init];
    if (self) {
        outputLeft  = [OCSParam paramWithString:[NSString stringWithFormat:@"%@%@",[self opcodeName], @"L"]];
        outputRight = [OCSParam paramWithString:[NSString stringWithFormat:@"%@%@",[self opcodeName], @"R"]];
        inL       = leftInput;
        inR       = rightInput;
        threshold = dBThreshold;
        ratio     = compressionRatio;
        attack    = attackTime;
        release   = releaseTime;
    }
    return self; 
}

- (NSString *) udoFile {
    return [[NSBundle mainBundle] pathForResource: @"CSGrainCompressor" ofType: @"udo"];
}

- (NSString *)stringForCSD
{
    return [NSString stringWithFormat:
            @"%@, %@ Compressor %@, %@, %@, %@, %@, %@\n",
            outputLeft, outputRight, inL, inR, threshold, ratio, attack, release];
}


@end
