//
//  OCSBandRejectButterworthFilter.m
//  OCS iPad Examples
//
//  Created by Adam Boulanger on 9/12/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSBandRejectButterworthFilter.h"

@interface OCSBandRejectButterworthFilter ()
{
    OCSParameter *input;
    OCSControl *center;
    OCSControl *bandwidth;
    
    BOOL isInitSkipped;
}
@end

@implementation OCSBandRejectButterworthFilter

-(id)initWithInput:(OCSParameter *)inputSignal
   centerFrequency:(OCSControl *)centerFrequency
         bandwidth:(OCSControl *)bandwidthRange
{
    self = [super initWithString:[self operationName]];
    if(self) {
        input = inputSignal;
        center = centerFrequency;
        bandwidth = bandwidthRange;
    }
    return self;
}

-(NSString *)stringForCSD
{
    return [NSString stringWithFormat:
            @"%@ butterbr %@, %@, %@, %d",
            self, input, center, bandwidth, 0];
}

@end