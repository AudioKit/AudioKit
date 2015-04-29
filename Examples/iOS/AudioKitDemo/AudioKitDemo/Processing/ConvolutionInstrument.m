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
        
        // Controls
        _dishWellBalance = [self createPropertyWithValue:0 minimum:0 maximum:1];
        _dryWetBalance   = [self createPropertyWithValue:0 minimum:0 maximum:0.1];
        
        // Instrument definition
        NSString *dish = [AKManager pathToSoundFile:@"dish"      ofType:@"wav"];
        NSString *well = [AKManager pathToSoundFile:@"Stairwell" ofType:@"wav"];
        
        AKConvolution *dishConv = [[AKConvolution alloc] initWithInput:input
                                               impulseResponseFilename:dish];
        
        AKConvolution *wellConv = [[AKConvolution alloc] initWithInput:input
                                               impulseResponseFilename:well];
        
        AKMix *balance = [[AKMix alloc] initWithInput1:dishConv
                                                input2:wellConv
                                               balance:_dishWellBalance];
        
        AKMix *dryWet = [[AKMix alloc] initWithInput1:input
                                               input2:balance
                                              balance:_dryWetBalance];
        
        [self setAudioOutput:[dryWet scaledBy:akp(3.0)]];

        [self resetParameter:input];
        
    }
    return self;
}


@end
