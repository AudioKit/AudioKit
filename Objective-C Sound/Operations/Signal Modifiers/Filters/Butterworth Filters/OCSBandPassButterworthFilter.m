//
//  OCSBandPassButterworthFilter.m
//  Objective-C Sound
//
//  Created by Adam Boulanger on 9/12/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSBandPassButterworthFilter.h"

@interface OCSBandPassButterworthFilter ()
{
    OCSAudio *input;
    OCSControl *center;
    OCSControl *bandwidth;
    
    BOOL isInitSkipped;
}
@end

@implementation OCSBandPassButterworthFilter

- (instancetype)initWithAudioSource:(OCSAudio *)audioSource
                    centerFrequency:(OCSControl *)centerFrequency
                          bandwidth:(OCSControl *)bandwidthRange
{
    self = [super initWithString:[self operationName]];
    if(self) {
        input = audioSource;
        center = centerFrequency;
        bandwidth = bandwidthRange;
    }
    return self;
}

- (NSString *)stringForCSD
{
    return [NSString stringWithFormat:
            @"%@ butterbp %@, %@, %@, %d",
            self, input, center, bandwidth, 0];
}

@end
