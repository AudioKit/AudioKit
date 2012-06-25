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
    OCSParam *inputLeft;
    OCSParam *inputRight;
    OCSParamControl *threshold;
    OCSParamControl *ratio;
    OCSParamControl *attackTime;
    OCSParamControl *releaseTime;
}
@end

@implementation UDOCsGrainCompressor

@synthesize outputLeft;
@synthesize outputRight;

- (id)initWithInputLeft:(OCSParam *)leftInput
             InputRight:(OCSParam *)rightInput
            ThresholdDB:(OCSParamControl *)dBThreshold
                  Ratio:(OCSParamControl *)compressionRatio
             AttackTime:(OCSParamControl *)attackTimeInSeconds
            ReleaseTime:(OCSParamControl *)releaseTimeInSeconds;
{
    self = [super init];
    if (self) {
        outputLeft  = [OCSParam paramWithString:[NSString stringWithFormat:@"%@%@",[self opcodeName], @"L"]];
        outputRight = [OCSParam paramWithString:[NSString stringWithFormat:@"%@%@",[self opcodeName], @"R"]];
        inputLeft   = leftInput;
        inputRight  = rightInput;
        threshold   = dBThreshold;
        ratio       = compressionRatio;
        attackTime  = attackTimeInSeconds;
        releaseTime = releaseTimeInSeconds;
    }
    return self; 
}

- (NSString *) file {
    return [[NSBundle mainBundle] pathForResource: @"CSGrainCompressor" ofType: @"udo"];
}

- (NSString *)stringForCSD
{
    return [NSString stringWithFormat:
            @"%@, %@ Compressor %@, %@, %@, %@, %@, %@\n",
            outputLeft, outputRight, inputLeft, inputRight, threshold, ratio, attackTime, releaseTime];
}


@end
