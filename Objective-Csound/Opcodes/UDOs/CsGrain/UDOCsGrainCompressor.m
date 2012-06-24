//
//  UDOCompressor.m
//  ExampleProject
//
//  Created by Aurelius Prochazka on 6/22/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "UDOCsGrainCompressor.h"

@implementation UDOCsGrainCompressor

@synthesize outputLeft;
@synthesize outputRight;

- (id)initWithInputLeft:(OCSParam *)inL
             InputRight:(OCSParam *)inR
              Threshold:(OCSParamControl *)thr
                  Ratio:(OCSParamControl *)rat 
                 Attack:(OCSParamControl *)atk
                Release:(OCSParamControl *)rel
{
    self = [super init];
    if (self) {
        outputLeft  = [OCSParam paramWithString:[NSString stringWithFormat:@"%@%@",[self opcodeName], @"L"]];
        outputRight = [OCSParam paramWithString:[NSString stringWithFormat:@"%@%@",[self opcodeName], @"R"]];
        inputLeft   = inL;
        inputRight  = inR;
        threshold   = thr;
        ratio       = rat;
        attack      = atk;
        release     = rel;
    }
    return self; 
}

- (NSString *) file {
    return [[NSBundle mainBundle] pathForResource: @"CSGrainCompressor" ofType: @"udo"];
}

- (NSString *)stringForCSD
{
    return [NSString stringWithFormat:
            @"%@, %@ Compressor %@, %@, %@, %@, %@, %@\n",
            outputLeft, outputRight, inputLeft, inputRight, threshold, ratio, attack, release];
}


@end
