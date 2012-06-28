//
//  ConvolutionInstrument.h
//  ExampleProject
//
//  Created by Aurelius Prochazka on 6/27/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSInstrument.h"

@interface ConvolutionInstrument : OCSInstrument

@property (nonatomic, strong) OCSProperty *dishWellBalance;
@property (nonatomic, strong) OCSProperty *dryWetBalance;

@end
