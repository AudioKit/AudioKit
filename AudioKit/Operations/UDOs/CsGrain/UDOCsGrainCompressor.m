//
//  UDOCompressor.m
//  Objective-C Sound
//
//  Created by Aurelius Prochazka on 6/22/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "UDOCsGrainCompressor.h"


@interface UDOCsGrainCompressor () {
    OCSStereoAudio *inLR;
    OCSControl *threshold;
    OCSControl *ratio;
    OCSControl *attack;
    OCSControl *release;
}
@end

@implementation UDOCsGrainCompressor

- (instancetype)initWithSourceStereoAudio:(OCSStereoAudio *)sourceStereo
                                threshold:(OCSControl *)dBThreshold
                         compressionRatio:(OCSControl *)compressionRatio
                               attackTime:(OCSControl *)attackTime
                              releaseTime:(OCSControl *)releaseTime
{
    self = [super init];
    if (self) {
        inLR      = sourceStereo;
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
            @"%@ Compressor %@, %@, %@, %@, %@",
            self, inLR, threshold, ratio, attack, release];
}


@end
