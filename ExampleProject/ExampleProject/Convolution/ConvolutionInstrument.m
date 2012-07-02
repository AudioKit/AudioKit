//
//  ConvolutionInstrument.m
//  ExampleProject
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
    OCSProperty *dishWellBalance;
    OCSProperty *dryWetBalance;
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
        dishWellBalance = [[OCSProperty alloc] initWithValue:0.0 minValue:kDishWellBalanceMin maxValue:kDishWellBalanceMax];
        dryWetBalance   = [[OCSProperty alloc] initWithValue:0.0 minValue:kDryWetBalanceMin   maxValue:kDryWetBalanceMax];
        
        [self addProperty:dishWellBalance];
        [self addProperty:dryWetBalance];         
        
        // INSTRUMENT DEFINITION ===============================================
        
        NSString *file;
        file = [[NSBundle mainBundle] pathForResource:@"808loop" ofType:@"wav"];
        OCSFileInput *loop = [[OCSFileInput alloc] initWithFilename:file];
        [self addOpcode:loop];
        
        NSString *dishL = [[NSBundle mainBundle] pathForResource:@"dishL" ofType:@"wav"];
        NSString *dishR = [[NSBundle mainBundle] pathForResource:@"dishR" ofType:@"wav"];
        NSString *wellL = [[NSBundle mainBundle] pathForResource:@"StairwellL" ofType:@"wav"];
        NSString *wellR = [[NSBundle mainBundle] pathForResource:@"StairwellR" ofType:@"wav"];
        
        OCSConvolution *dishConvL;
        dishConvL  = [[OCSConvolution alloc] initWithInputAudio:[loop outputLeft] 
                                            impulseResponseFile:dishL];
        [self addOpcode:dishConvL];

        OCSConvolution *dishConvR;
        dishConvR  = [[OCSConvolution alloc] initWithInputAudio:[loop outputLeft] 
                                            impulseResponseFile:dishR];
        [self addOpcode:dishConvR];
        
        OCSConvolution *wellConvL;
        wellConvL  = [[OCSConvolution alloc] initWithInputAudio:[loop outputLeft] 
                                            impulseResponseFile:wellL];
        [self addOpcode:wellConvL];
        
        OCSConvolution *wellConvR;
        wellConvR  = [[OCSConvolution alloc] initWithInputAudio:[loop outputLeft] 
                                            impulseResponseFile:wellR];
        [self addOpcode:wellConvR];
        
        OCSWeightedMean *dishWellBalanceL;
        dishWellBalanceL = [[OCSWeightedMean alloc] initWithSignal1:[dishConvL output]
                                                            signal2:[wellConvL output]
                                                            balance:[dishWellBalance output]];
        [self addOpcode:dishWellBalanceL];

        OCSWeightedMean *dishWellBalanceR;
        dishWellBalanceR = [[OCSWeightedMean alloc] initWithSignal1:[dishConvR output]
                                                            signal2:[wellConvR output]
                                                            balance:[dishWellBalance output]];
        [self addOpcode:dishWellBalanceR];

        
        OCSWeightedMean *dryWetBalanceL;
        dryWetBalanceL = [[OCSWeightedMean alloc] initWithSignal1:[loop outputLeft]
                                                          signal2:[dishWellBalanceL output]
                                                          balance:[dryWetBalance output]];
        [self addOpcode:dryWetBalanceL];
        
        OCSWeightedMean *dryWetBalanceR;
        dryWetBalanceR = [[OCSWeightedMean alloc] initWithSignal1:[loop outputRight]
                                                          signal2:[dishWellBalanceR output]
                                                          balance:[dryWetBalance output]];
        [self addOpcode:dryWetBalanceR];
        

        // AUDIO OUTPUT ========================================================
        
        OCSAudio *audio = [[OCSAudio alloc] initWithLeftInput:[dryWetBalanceL output] 
                                                   rightInput:[dryWetBalanceR output]];
        [self addOpcode:audio];
    }
    return self;
}


@end
