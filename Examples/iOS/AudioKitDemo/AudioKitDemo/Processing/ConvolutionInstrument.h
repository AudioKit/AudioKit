//
//  ConvolutionInstrument.h
//  AudioKit Example
//
//  Created by Aurelius Prochazka on 6/27/12.
//  Copyright (c) 2012 Aurelius Prochazka. All rights reserved.
//

#import "AKFoundation.h"

@interface ConvolutionInstrument : AKInstrument

@property AKInstrumentProperty *dishWellBalance;
@property AKInstrumentProperty *dryWetBalance;

@property (readonly) AKAudio *auxilliaryOutput;

- (instancetype)initWithInput:(AKAudio *)input;

@end
