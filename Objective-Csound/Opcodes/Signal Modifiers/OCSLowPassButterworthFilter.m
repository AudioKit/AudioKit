//
//  OCSLowPassButterworthFilter.m
//  ExampleProject
//
//  Created by Adam Boulanger on 6/22/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSLowPassButterworthFilter.h"

@interface OCSLowPassButterworthFilter () {
    OCSParam *output;
    OCSParam *input;
    OCSControlParam *cutoff;
    
    BOOL isInitSkipped;
}
@end

@implementation OCSLowPassButterworthFilter
@synthesize output;

-(id)initWithInput:(OCSParam *)inputSignal 
   cutoffFrequency:(OCSControlParam *)cutoffFrequency;
{
    self = [super init];
    if(self) {
        output = [OCSParam paramWithString:[self opcodeName]];
        input = inputSignal;
        cutoff = cutoffFrequency;
    }
    return self;
}

-(NSString *)stringForCSD
{
    return [NSString stringWithFormat:@"%@ butterlp %@, %@, %d", output, input, cutoff, 0];
}

-(NSString *) description {
    return [output parameterString];
}

@end
