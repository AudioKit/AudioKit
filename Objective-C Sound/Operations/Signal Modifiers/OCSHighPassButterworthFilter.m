//
//  OCSHighPassButterworthFilter.m
//  Sonification
//
//  Created by Adam Boulanger on 10/10/12.
//  Copyright (c) 2012 Adam Boulanger. All rights reserved.
//

#import "OCSHighPassButterworthFilter.h"

@interface OCSHighPassButterworthFilter () {
    OCSParameter *output;
    OCSParameter *input;
    OCSControl *cutoff;
    
    BOOL isInitSkipped;
}
@end

@implementation OCSHighPassButterworthFilter

-(id)initWithInput:(OCSParameter *)inputSignal
   cutoffFrequency:(OCSControl *)cutoffFrequency;
{
    self = [super init];
    if(self) {
        output = [OCSParameter parameterWithString:[self operationName]];
        input = inputSignal;
        cutoff = cutoffFrequency;
    }
    return self;
}

-(NSString *)stringForCSD
{
    return [NSString stringWithFormat:@"%@ butterhp %@, %@, %d", output, input, cutoff, 0];
}

-(NSString *) description {
    return [output parameterString];
}

@end