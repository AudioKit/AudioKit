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
    OCSParameter *output;
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
    self = [super init];
    if(self) {
        output = [OCSParameter parameterWithString:[self operationName]];
        input = inputSignal;
        center = centerFrequency;
        bandwidth = bandwidthRange;
    }
    return self;
}

-(NSString *)stringForCSD
{
    return [NSString stringWithFormat:@"%@ butterbr %@, %@, %@, %d", output, input, center, bandwidth, 0];
}

-(NSString *) description {
    return [output parameterString];
}

@end