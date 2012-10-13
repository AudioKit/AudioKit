//
//  OCSHighPassButterworthFilter.m
//  Sonification
//
//  Created by Adam Boulanger on 10/10/12.
//  Copyright (c) 2012 Adam Boulanger. All rights reserved.
//

#import "OCSHighPassButterworthFilter.h"

@interface OCSHighPassButterworthFilter () {
    OCSParameter *input;
    OCSControl *cutoff;
}
@end

@implementation OCSHighPassButterworthFilter

-(id)initWithInput:(OCSAudio *)inputSignal
   cutoffFrequency:(OCSControl *)cutoffFrequency;
{
    self = [super initWithString:[self operationName]];
    if(self) {
        input = inputSignal;
        cutoff = cutoffFrequency;
    }
    return self;
}

-(NSString *)stringForCSD
{
    return [NSString stringWithFormat:
            @"%@ butterhp %@, %@, %d",
            self, input, cutoff, 0];
}

@end