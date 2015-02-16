//
//  ConvolutionInstrument.m
//  AudioKit Example
//
//  Created by Aurelius Prochazka on 6/27/12.
//  Copyright (c) 2012 Aurelius Prochazka. All rights reserved.
//

#import "ConvolutionInstrument.h"

@implementation ConvolutionInstrument

- (instancetype)initWithInput:(AKAudio *)input
{
    self = [super init];
    if (self) {
        
        // INPUTS AND CONTROLS =================================================
        _dishWellBalance = [[AKInstrumentProperty alloc] initWithValue:0
                                                               minimum:0
                                                               maximum:1.0];
        [self addProperty:_dishWellBalance];
        
        _dryWetBalance = [[AKInstrumentProperty alloc] initWithValue:0
                                                             minimum:0
                                                             maximum:0.1];
        [self addProperty:_dryWetBalance];
        
        // INSTRUMENT DEFINITION ===============================================
        NSString *dish = [[NSBundle mainBundle] pathForResource:@"dish" ofType:@"wav"];
        NSString *well = [[NSBundle mainBundle] pathForResource:@"Stairwell" ofType:@"wav"];
        
        AKConvolution *dishConv;
        dishConv = [[AKConvolution alloc] initWithInput:input
                                      impulseResponseFilename:dish];
        [self connect:dishConv];
        
        
        AKConvolution *wellConv;
        wellConv  = [[AKConvolution alloc] initWithInput:input
                                       impulseResponseFilename:well];
        [self connect:wellConv];
        
        
        AKMix *balance;
        balance = [[AKMix alloc] initWithInput1:dishConv
                                             input2:wellConv
                                            balance:_dishWellBalance];
        [self connect:balance];
        
        
        AKMix *dryWet;
        dryWet = [[AKMix alloc] initWithInput1:input
                                        input2:balance
                                       balance:_dryWetBalance];
        [self connect:dryWet];
        
        // AUDIO OUTPUT ========================================================
        
        AKAudioOutput *audio = [[AKAudioOutput alloc] initWithAudioSource:dryWet];
        [self connect:audio];
        
        // EXTERNAL OUTPUTS ====================================================
        // After your instrument is set up, define outputs available to others
        _auxilliaryOutput = [AKAudio globalParameter];
        [self assignOutput:_auxilliaryOutput to:dryWet];
        
        [self resetParameter:input];
        
    }
    return self;
}


@end
