//
//  ToneGenerator.h
//  Objective-Csound Example
//
//  Created by Aurelius Prochazka on 6/9/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSInstrument.h"

@interface ToneGenerator : OCSInstrument 

@property (nonatomic, strong) OCSProperty *frequency;
#define kFrequencyMin 110
#define kFrequencyMax 880

@property (readonly) OCSParameter *auxilliaryOutput;

@end
