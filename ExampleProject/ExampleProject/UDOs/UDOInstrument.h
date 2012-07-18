//
//  UDOInstrument.h
//  Objective-Csound Example
//
//  Created by Aurelius Prochazka on 6/23/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSInstrument.h"

@interface UDOInstrument : OCSInstrument 

@property (nonatomic, strong) OCSInstrumentProperty *frequency;
#define kFrequencyMin 110
#define kFrequencyMax 880

@end
