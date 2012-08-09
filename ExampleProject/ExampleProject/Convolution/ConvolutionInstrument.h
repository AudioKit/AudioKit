//
//  ConvolutionInstrument.h
//  Objective-C Sound Example
//
//  Created by Aurelius Prochazka on 6/27/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSInstrument.h"

@interface ConvolutionInstrument : OCSInstrument

@property (nonatomic, strong) OCSInstrumentProperty *dishWellBalance;
#define kDishWellBalanceInit 0.0
#define kDishWellBalanceMin  0.0
#define kDishWellBalanceMax  1.0

@property (nonatomic, strong) OCSInstrumentProperty *dryWetBalance;
#define kDryWetBalanceInit 0.0
#define kDryWetBalanceMin  0.0
#define kDryWetBalanceMax  0.1

@end
