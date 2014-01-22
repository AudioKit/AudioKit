//
//  ConvolutionInstrument.h
//  AudioKit Example
//
//  Created by Aurelius Prochazka on 6/27/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "AKFoundation.h"

@interface ConvolutionInstrument : AKInstrument

@property (nonatomic, strong) AKInstrumentProperty *dishWellBalance;
#define kDishWellBalanceInit 0.0
#define kDishWellBalanceMin  0.0
#define kDishWellBalanceMax  1.0

@property (nonatomic, strong) AKInstrumentProperty *dryWetBalance;
#define kDryWetBalanceInit 0.0
#define kDryWetBalanceMin  0.0
#define kDryWetBalanceMax  0.1

@end
