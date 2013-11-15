//
//  ConvolutionInstrument.m
//  Objective-C Sound Example
//
//  Created by Aurelius Prochazka on 6/27/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "ConvolutionInstrument.h"

@implementation ConvolutionInstrument

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        // INPUTS AND CONTROLS =================================================
        _dishWellBalance = [[OCSInstrumentProperty alloc] initWithValue:kDishWellBalanceInit
                                                               minValue:kDishWellBalanceMin
                                                               maxValue:kDishWellBalanceMax];
        _dryWetBalance   = [[OCSInstrumentProperty alloc] initWithValue:kDryWetBalanceInit
                                                               minValue:kDryWetBalanceMin
                                                               maxValue:kDryWetBalanceMax];
        
        [self addProperty:_dishWellBalance];
        [self addProperty:_dryWetBalance];
        
        // INSTRUMENT DEFINITION ===============================================
        
        NSString *file;
        file = [[NSBundle mainBundle] pathForResource:@"808loop" ofType:@"wav"];
        OCSFileInput *loop = [[OCSFileInput alloc] initWithFilename:file];
        [self connect:loop];
        
        NSString *dish = [[NSBundle mainBundle] pathForResource:@"dish" ofType:@"wav"];
        NSString *well = [[NSBundle mainBundle] pathForResource:@"Stairwell" ofType:@"wav"];
        
        OCSConvolution *dishConv;
        dishConv  = [[OCSConvolution alloc] initWithAudioSource:loop.leftOutput
                                            impulseResponseFile:dish];
        [self connect:dishConv];
        
        
        OCSConvolution *wellConv;
        wellConv  = [[OCSConvolution alloc] initWithAudioSource:loop.rightOutput
                                            impulseResponseFile:well];
        [self connect:wellConv];
        
        
        OCSMixedAudio *balance;
        balance = [[OCSMixedAudio alloc] initWithSignal1:dishConv
                                                 signal2:wellConv
                                                 balance:_dishWellBalance];
        [self connect:balance];
        
        
        OCSMixedAudio *dryWet;
        dryWet = [[OCSMixedAudio alloc] initWithSignal1:loop.leftOutput
                                                signal2:balance
                                                balance:_dryWetBalance];
        [self connect:dryWet];
        
        
        
        // AUDIO OUTPUT ========================================================
        
        OCSAudioOutput *audio = [[OCSAudioOutput alloc] initWithAudioSource:dryWet];
        [self connect:audio];
    }
    return self;
}


@end
