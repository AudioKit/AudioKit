//
//  UDOCompressor.m
//  Objective-C Sound
//
//  Created by Aurelius Prochazka on 6/22/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "UDOCsGrainCompressor.h"


@interface UDOCsGrainCompressor () {
    OCSParameter *leftOutput;
    OCSParameter *rightOutput;
    OCSParameter *inL;
    OCSParameter *inR;
    OCSControl *threshold;
    OCSControl *ratio;
    OCSControl *attack;
    OCSControl *release;
}
@end

@implementation UDOCsGrainCompressor

@synthesize leftOutput;
@synthesize rightOutput;

- (id)initWithLeftInput:(OCSParameter *)leftInput
             rightInput:(OCSParameter *)rightInput
              threshold:(OCSControl *)dBThreshold
       compressionRatio:(OCSControl *)compressionRatio
             attackTime:(OCSControl *)attackTime
            releaseTime:(OCSControl *)releaseTime;
{
    self = [super init];
    if (self) {
        leftOutput  = [OCSParameter parameterWithString:[NSString stringWithFormat:@"%@%@",[self operationName], @"L"]];
        rightOutput = [OCSParameter parameterWithString:[NSString stringWithFormat:@"%@%@",[self operationName], @"R"]];
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
    return [[NSBundle mainBundle] pathForResource: @"CsGrainCompressor" ofType: @"udo"];
}

- (NSString *)stringForCSD
{
    return [NSString stringWithFormat:
            @"%@, %@ Compressor %@, %@, %@, %@, %@, %@",
            leftOutput, rightOutput, inL, inR, threshold, ratio, attack, release];
}


@end
