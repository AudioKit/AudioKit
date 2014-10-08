//
//  AKCompressor.m
//  AudioKit
//
//  Auto-generated from scripts by Aurelius Prochazka on 11/25/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//
//  Implementation of Csound's compress:
//  http://www.csounds.com/manual/html/compress.html
//

#import "AKCompressor.h"

@implementation AKCompressor
{
    AKAudio *aasig;
    AKAudio *acsig;
    AKControl *kthresh;
    AKControl *kloknee;
    AKControl *khiknee;
    AKControl *kratio;
    AKControl *katt;
    AKControl *krel;
    AKConstant *ilook;
}

- (instancetype)initWithAffectedAudioSource:(AKAudio *)affectedAudioSource
                     controllingAudioSource:(AKAudio *)controllingAudioSource
                                  threshold:(AKControl *)threshold
                                    lowKnee:(AKControl *)lowKnee
                                   highKnee:(AKControl *)highKnee
                           compressionRatio:(AKControl *)compressionRatio
                                 attackTime:(AKControl *)attackTime
                                releaseTime:(AKControl *)releaseTime
{
    self = [super initWithString:[self operationName]];
    if (self) {
        aasig = affectedAudioSource;
        acsig = controllingAudioSource;
        kthresh = threshold;
        kloknee = lowKnee;
        khiknee = highKnee;
        kratio = compressionRatio;
        katt = attackTime;
        krel = releaseTime;
        ilook = akp(0.05);
    }
    return self;
}

- (void)setOptionalLookAheadTime:(AKConstant *)lookAheadTime {
	ilook = lookAheadTime;
}

- (NSString *)stringForCSD {
    return [NSString stringWithFormat:
            @"%@ compress %@, %@, %@, %@, %@, %@, %@, %@, %@",
            self, aasig, acsig, kthresh, kloknee, khiknee, kratio, katt, krel, ilook];
}

@end