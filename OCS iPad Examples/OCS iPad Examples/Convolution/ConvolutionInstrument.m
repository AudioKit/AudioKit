//
//  ConvolutionInstrument.m
//  Objective-C Sound Example
//
//  Created by Aurelius Prochazka on 6/27/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "ConvolutionInstrument.h"
#import "OCSFileInput.h"
#import "OCSConvolution.h"
#import "OCSWeightedMean.h"
#import "OCSAudio.h"

@interface ConvolutionInstrument () {
    OCSInstrumentProperty *dishWellBalance;
    OCSInstrumentProperty *dryWetBalance;
}
@end

@implementation ConvolutionInstrument

@synthesize dishWellBalance;
@synthesize dryWetBalance;

- (id)init 
{
    self = [super init];
    if (self) { 
        
        // INPUTS AND CONTROLS =================================================
        dishWellBalance = [[OCSInstrumentProperty alloc] initWithValue:kDishWellBalanceInit 
                                                              minValue:kDishWellBalanceMin 
                                                              maxValue:kDishWellBalanceMax];
        dryWetBalance   = [[OCSInstrumentProperty alloc] initWithValue:kDryWetBalanceInit 
                                                              minValue:kDryWetBalanceMin   
                                                              maxValue:kDryWetBalanceMax];
        
        [dishWellBalance setControl:[OCSControl parameterWithString:@"dishWellBalance"]]; 
        [dryWetBalance   setControl:[OCSControl parameterWithString:@"dryWetBalance"]]; 
        [self addProperty:dishWellBalance];
        [self addProperty:dryWetBalance];         
        
        // INSTRUMENT DEFINITION ===============================================
        
        NSString *file;
        file = [[NSBundle mainBundle] pathForResource:@"808loop" ofType:@"wav"];
        OCSFileInput *loop = [[OCSFileInput alloc] initWithFilename:file];
        [self addOpcode:loop];
        
        NSString *dish = [[NSBundle mainBundle] pathForResource:@"dish" ofType:@"wav"];
        NSString *well = [[NSBundle mainBundle] pathForResource:@"Stairwell" ofType:@"wav"];
        
        OCSConvolution *dishConv;
        dishConv  = [[OCSConvolution alloc] initWithInputAudio:[loop leftOutput] 
                                           impulseResponseFile:dish];
        [self addOpcode:dishConv];

        
        OCSConvolution *wellConv;
        wellConv  = [[OCSConvolution alloc] initWithInputAudio:[loop rightOutput] 
                                           impulseResponseFile:well];
        [self addOpcode:wellConv];

        
        OCSWeightedMean *balance;
        balance = [[OCSWeightedMean alloc] initWithSignal1:[dishConv output]
                                                   signal2:[wellConv output]
                                                   balance:[dishWellBalance output]];
        [self addOpcode:balance];

        
        OCSWeightedMean *dryWet;
        dryWet = [[OCSWeightedMean alloc] initWithSignal1:[loop leftOutput]
                                                  signal2:[balance output]
                                                  balance:[dryWetBalance control]];
        [self addOpcode:dryWet];
        
        

        // AUDIO OUTPUT ========================================================
        
        OCSAudio *audio = [[OCSAudio alloc] initWithMonoInput:[dryWet output]];
        [self addOpcode:audio];
    }
    return self;
}


@end
