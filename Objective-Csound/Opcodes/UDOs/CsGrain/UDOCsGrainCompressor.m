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
    OCSControlParam *threshold;
    OCSControlParam *ratio;
    OCSControlParam *attack;
    OCSControlParam *release;
}
@end

@implementation UDOCsGrainCompressor

@synthesize outputLeft;
@synthesize outputRight;

- (id)initWithLeftInput:(OCSParam *)leftInput
             rightInput:(OCSParam *)rightInput
              threshold:(OCSControlParam *)dBThreshold
       compressionRatio:(OCSControlParam *)compressionRatio
             attackTime:(OCSControlParam *)attackTime
            releaseTime:(OCSControlParam *)releaseTime;
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
            @"%@, %@ Compressor %@, %@, %@, %@, %@, %@",
            outputLeft, outputRight, inL, inR, threshold, ratio, attack, release];
}


@end
