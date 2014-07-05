//
//  UDOCompressor.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 6/22/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "UDOCSGrainCompressor.h"


@interface UDOCSGrainCompressor () {
    AKStereoAudio *inLR;
    AKControl *threshold;
    AKControl *ratio;
    AKControl *attack;
    AKControl *release;
}
@end

@implementation UDOCSGrainCompressor

- (instancetype)initWithSourceStereoAudio:(AKStereoAudio *)sourceStereo
                                threshold:(AKControl *)dBThreshold
                         compressionRatio:(AKControl *)compressionRatio
                               attackTime:(AKControl *)attackTime
                              releaseTime:(AKControl *)releaseTime
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
