//
//  SimpleOscillator.h
//  Objective-C Sound Example
//
//  Created by Aurelius Prochazka on 6/1/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSInstrument.h"

@interface SimpleOscillator : OCSInstrument

@property (nonatomic, strong) OCSNoteProperty *frequency;
#define kFrequencyMin 110
#define kFrequencyMax 880

@end
