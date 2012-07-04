//
//  ConvolutionInstrument.h
//  Objective-Csound Example
//
//  Created by Aurelius Prochazka on 6/27/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSInstrument.h"

@interface ConvolutionInstrument : OCSInstrument

@property (nonatomic, strong) OCSProperty *dishWellBalance;
#define kDishWellBalanceMin 0.0
#define kDishWellBalanceMax 1.0

@property (nonatomic, strong) OCSProperty *dryWetBalance;
#define kDryWetBalanceMin 0.0
#define kDryWetBalanceMax 0.1

@end
