//
//  ConvolutionInstrument.m
//  AudioKit Example
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
        _dishWellBalance = [[AKInstrumentProperty alloc] initWithValue:0
                                                           minimumValue:0
                                                           maximumValue:1.0];
        _dryWetBalance   = [[AKInstrumentProperty alloc] initWithValue:0
                                                           minimumValue:0
                                                           maximumValue:0.1];
        
        [self addProperty:_dishWellBalance];
        [self addProperty:_dryWetBalance];
        
        // INSTRUMENT DEFINITION ===============================================
        
        NSString *file;
        file = [[NSBundle mainBundle] pathForResource:@"808loop" ofType:@"wav"];
        AKFileInput *loop = [[AKFileInput alloc] initWithFilename:file];
        [self connect:loop];
        
        NSString *dish = [[NSBundle mainBundle] pathForResource:@"dish" ofType:@"wav"];
        NSString *well = [[NSBundle mainBundle] pathForResource:@"Stairwell" ofType:@"wav"];
        
        AKConvolution *dishConv;
        dishConv  = [[AKConvolution alloc] initWithAudioSource:loop.leftOutput
                                            impulseResponseFile:dish];
        [self connect:dishConv];
        
        
        AKConvolution *wellConv;
        wellConv  = [[AKConvolution alloc] initWithAudioSource:loop.rightOutput
                                            impulseResponseFile:well];
        [self connect:wellConv];
        
        
        AKMixedAudio *balance;
        balance = [[AKMixedAudio alloc] initWithSignal1:dishConv
                                                 signal2:wellConv
                                                 balance:_dishWellBalance];
        [self connect:balance];
        
        
        AKMixedAudio *dryWet;
        dryWet = [[AKMixedAudio alloc] initWithSignal1:loop.leftOutput
                                                signal2:balance
                                                balance:_dryWetBalance];
        [self connect:dryWet];
        
        
        
        // AUDIO OUTPUT ========================================================
        
        AKAudioOutput *audio = [[AKAudioOutput alloc] initWithAudioSource:dryWet];
        [self connect:audio];
    }
    return self;
}


@end
