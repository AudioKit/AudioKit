//
//  OCSCompressor.m
//  Objective-C Sound
//
//  Auto-generated from database on 11/25/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//
//  Implementation of Csound's compress:
//  http://www.csounds.com/manual/html/compress.html
//

#import "OCSCompressor.h"

@interface OCSCompressor () {
    OCSAudio *aasig;
    OCSAudio *acsig;
    OCSControl *kthresh;
    OCSControl *kloknee;
    OCSControl *khiknee;
    OCSControl *kratio;
    OCSControl *katt;
    OCSControl *krel;
    OCSConstant *ilook;
}
@end

@implementation OCSCompressor

- (instancetype)initWithAffectedAudioSource:(OCSAudio *)affectedAudioSource
           controllingAudioSource:(OCSAudio *)controllingAudioSource
                        threshold:(OCSControl *)threshold
                          lowKnee:(OCSControl *)lowKnee
                         highKnee:(OCSControl *)highKnee
                 compressionRatio:(OCSControl *)compressionRatio
                       attackTime:(OCSControl *)attackTime
                      releaseTime:(OCSControl *)releaseTime
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
        ilook = ocsp(0.05);
    }
    return self;
}

- (void)setOptionalLookAheadTime:(OCSConstant *)lookAheadTime {
	ilook = lookAheadTime;
}

- (NSString *)stringForCSD {
    return [NSString stringWithFormat:
            @"%@ compress %@, %@, %@, %@, %@, %@, %@, %@, %@",
            self, aasig, acsig, kthresh, kloknee, khiknee, kratio, katt, krel, ilook];
}

@end