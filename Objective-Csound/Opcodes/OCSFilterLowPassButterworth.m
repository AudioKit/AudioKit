//
//  OCSFilterLowPassButter.m
//  ExampleProject
//
//  Created by Adam Boulanger on 6/22/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSFilterLowPassButterworth.h"

@interface OCSFilterLowPassButterworth () {
    OCSParam *output;
    OCSParam *input;
    OCSParamControl *cutoff;
    
    BOOL isInitSkipped;
}
@end

@implementation OCSFilterLowPassButterworth
@synthesize output;

-(id)initWithInput:(OCSParam *)inputSignal 
   CutoffFrequency:(OCSParamControl *)cutoffFrequency;
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
    return [NSString stringWithFormat:@"%@ butterlp %@, %@, %d\n", output, input, cutoff, 0];
}

-(NSString *) description {
    return [output parameterString];
}

@end
