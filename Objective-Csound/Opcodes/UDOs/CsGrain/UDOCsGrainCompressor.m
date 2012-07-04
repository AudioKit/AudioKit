//
//  UDOCompressor.m
//  Objective-Csound
//
//  Created by Aurelius Prochazka on 6/22/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "UDOCsGrainCompressor.h"


@interface UDOCsGrainCompressor () {
    OCSParameter *outputLeft;
    OCSParameter *outputRight;
    OCSParameter *inL;
    OCSParameter *inR;
    OCSControl *threshold;
    OCSControl *ratio;
    OCSControl *attack;
    OCSControl *release;
}
@end

@implementation UDOCsGrainCompressor

@synthesize outputLeft;
@synthesize outputRight;

- (id)initWithLeftInput:(OCSParameter *)leftInput
             rightInput:(OCSParameter *)rightInput
              threshold:(OCSControl *)dBThreshold
       compressionRatio:(OCSControl *)compressionRatio
             attackTime:(OCSControl *)attackTime
            releaseTime:(OCSControl *)releaseTime;
{
    self = [super init];
    if (self) {
        outputLeft  = [OCSParameter parameterWithString:[NSString stringWithFormat:@"%@%@",[self opcodeName], @"L"]];
        outputRight = [OCSParameter parameterWithString:[NSString stringWithFormat:@"%@%@",[self opcodeName], @"R"]];
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
