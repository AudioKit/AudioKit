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

-(id)initWithInput:(OCSParam *)i Cutoff:(OCSParamControl *)freq
{
    self = [super init];
    if(self) {
        output = [OCSParam paramWithString:[self opcodeName]];
        input = i;
        cutoff = freq;
        
        isInitSkipped = NO;
    }
    return self;
}

-(id)initWithInput:(OCSParam *)i Cutoff:(OCSParamControl *)freq SkipInit:(BOOL)isSkipped
{
    self = [super init];
    if(self) {
        output = [OCSParam paramWithString:[self opcodeName]];
        input = i;
        cutoff = freq;
    
        isInitSkipped = isSkipped;
    }
    return self;
}


-(NSString *)stringForCSD
{
    int skip = isInitSkipped ? 1 : 0;
    return [NSString stringWithFormat:@"%@ butterlp %@, %@, %d", output, input, cutoff, skip];
}

-(NSString *) description {
    return [output parameterString];
}

@end
